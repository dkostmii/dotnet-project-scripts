<#

.SYNOPSIS
Compress project folder to zip archive

.DESCRIPTION
Adds project folder contents to ZIP archive. If no project name provided, chooses the first folder in PWD. This script depends on Clean-Project.ps1 script in order to clean project structure before compressing.

.PARAMETER
Project name to be compressed. If no such provided, defaults to first directory in PWD.

.EXAMPLE
.\Compress-Project

.EXAMPLE
.\Compress-Project -projectName MyAwesomeProject

#>

param(
  [string] $projectName
)

try {
  Get-Item .\Clean-Project.ps1
}
catch {
  Write-Host "Unable to clean project structure as Clean-Project.ps1 script missing." -ForegroundColor Yellow
}

if ($projectName) {
  $projectName = Split-Path $projectName -Leaf

  if (Test-Path "$projectName.zip" -PathType Leaf) {
    Write-Host "Arhive with project '$projectName' already exists." -ForegroundColor Yellow
    Write-Host "Do you want to replace it [y/N]: "

    $key = [Console]::ReadKey().KeyChar.ToString().ToLower()
    if ($key -ne "y") {
      Write-Host "Exiting..."
      exit 1
    }
    Write-Output ""
    Write-Output "Removing existing archive with project '$projectName'..."

    Remove-Item "$projectName.zip" -Force | Out-Null
  }

  if (-not (Test-Path $projectName -PathType Container)) {
    Write-Host "Project '$projectName' does not exist in this folder" -ForegroundColor Red
    exit 1
  }

  Write-Host "Compressing project '$projectName'..."
  Compress-Archive $projectName "$projectName.zip"
}
else {
  $dirs = (Get-ChildItem -Directory)

  if ($dirs.Length -eq 0) {
    Write-Host "No project directories at this location." -ForegroundColor Red
    exit 1
  }

  $projDir = $dirs[0]

  $name = $projDir.BaseName

  if (Test-Path "$name.zip" -PathType Leaf) {
    Write-Host "Arhive with project '$name' already exists." -ForegroundColor Yellow
    Write-Host "Do you want to replace it [y/N]: "

    $key = [Console]::ReadKey().KeyChar.ToString().ToLower()
    if ($key -ne "y") {
      Write-Host "Exiting..."
      exit 1
    }
    Write-Output ""
    Write-Output "Removing existing archive with project '$name'..."

    Remove-Item "$name.zip" -Force | Out-Null
  }

  Write-Host "Compressing project '$name'..."
  Compress-Archive $projDir ("$name.zip")
}

Write-Host "Done." -ForegroundColor Green
