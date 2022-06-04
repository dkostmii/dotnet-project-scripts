<#
  .SYNOPSIS
  Create new WinForms project using dotnet CLI

  .DESCRIPTION
  This script creates new WinForms .NET project using dotnet CLI

  .PARAMETER projectName
  Name of project to be created. Ignores path, so always is created in $pwd

  .PARAMETER importFrom
  Path to project to copy. Parameter is optional

  .EXAMPLE
  .\New-Project -projectName MyAwesomeProject

  Creates folder MyAwesomeProject containing solution file and project folder with the same name inside

  .EXAMPLE
  .\New-Project -projectName MyAwesomeProject -importFrom ".\MyAwesomeProject1"

  Creates folder MyAwesomeProject containing solution filde and project folder with same name inside. Then copies .cs and .resx files from project specified in -importFrom parameter
#>

param(
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string] $projectName = "UntitledProject",
  [string] $importFrom
)

try {
  Get-Command dotnet -ErrorAction Stop | Out-Null
}
catch {
  Write-Host "Seems you have not installed dotnet CLI." -ForegroundColor Red
  Write-Host "Download it on: " -NoNewline
  Write-Host "https://dotnet.microsoft.com/en-us/download" -BackgroundColor White -ForegroundColor Black
  exit 1
}

$projectName = (Split-Path $projectName -Leaf)

$projectPath = (Join-Path $projectName $projectName)

function Clone-Project {
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $AnotherProjectPath
  )

  if (-not (Test-Path $AnotherProjectPath -PathType Container)) {
    throw "Project not found $AnotherProjectPath"
    exit 1
  }

  $AnotherProjectName = (Split-Path $AnotherProjectPath -Leaf)
  $slnPath = (Join-Path $AnotherProjectPath "$AnotherProjectName.sln")
  $projPath = (Join-Path $AnotherProjectPath $AnotherProjectName)

  try {
    Get-Item $slnPath | Out-Null
  }
  catch {
    Write-Host "importProject's solution file not found at location: '$slnPath'" -ForegroundColor Red
    exit 1
  }

  try {
    Get-Item $projPath | Out-Null
  }
  catch {
    Write-Host "importProject's project directory not found at location: '$projPath'" -ForegroundColor Red
    exit 1
  }

  Get-ChildItem -Path $projPath
  | Where-Object { $_.Extension -eq ".cs" -or $_.Extension -eq ".resx" }
  | ForEach-Object { 
    Copy-Item $_ $projectPath -Force
  }

  Get-ChildItem -Path $projPath -Directory -Exclude obj, bin -Recurse
  | ForEach-Object {
    $folderRel = [IO.Path]::GetRelativePath((Resolve-Path $projPath), $_.FullName)
    $destFolder = (Join-Path $projectPath $folderRel)
    $srcFolder = (Join-Path $projPath $folderRel)

    New-Item $destFolder -ItemType Dir | Out-Null
    Get-ChildItem -Path $srcFolder -File
    | Where-Object { $_.Extension -eq ".cs" -or $_.Extension -eq ".resx" }
    | ForEach-Object { 
      Copy-Item $_ $destFolder -Force
    }
  }

  Get-ChildItem -Path $projectPath -File -Filter "*.cs" -Recurse | ForEach-Object {
    (Get-Content $_).replace($AnotherProjectName, $projectName) | Set-Content $_
  }
}

if (Test-Path $projectName -PathType Container) {
  Write-Host "Project with '$projectName' already exists." -ForegroundColor Yellow
  Write-Host "Do you want to replace it [y/N]: "

  $key = [Console]::ReadKey().KeyChar.ToString().ToLower()
  if ($key -ne "y") {
    Write-Host "Exiting..."
    exit 1
  }
  Write-Output ""
  Write-Output "Removing existing project '$projectName'"

  Remove-Item $projectName -Force -Recurse | Out-Null
}

Write-Output "Creating project $projectName"

New-Item $projectName -ItemType Dir | Out-Null

Set-Location $projectName | Out-Null

dotnet new sln | Out-Null

New-Item $projectName -ItemType Dir | Out-Null

Set-Location $projectName | Out-Null

dotnet new winforms | Out-Null

Set-Location .. | Out-Null

dotnet sln add $projectName | Out-Null

Set-Location .. | Out-Null

if ($importFrom) {
  Write-Output "Importing $importFrom project"
  Clone-Project -AnotherProjectPath $importFrom
}

Write-Host "Done." -ForegroundColor Green