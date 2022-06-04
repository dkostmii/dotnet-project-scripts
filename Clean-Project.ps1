<#

.SYNOPSIS
Remove project-identifying assets recursively (in current directory and all subdirectories)

.DESCRIPTION
Remove bin, obj and .vs folders from project file structure and .git folder optionally.

.PARAMETER CleanGit
Also clean the .git directory.

.EXAMPLE
.\Clean-Project

.EXAMPLE
.\Clean-Project -CleanGit

#>
param(
    [switch] $CleanGit = $false
)

function Remove-Targets {
    param(
        [string] $Path = ".\"
    )

    $targets = $("bin", "obj", ".vs")

    if (-not $IgnoreGit) {
        $targets += ".git"
    }

    (Get-ChildItem -Path $Path -Directory -Force)
    | Where-Object { $_.Name -in $targets }
    | ForEach-Object {
        Write-Host "[$Path] " -ForegroundColor Cyan -NoNewLine
        Write-Host "Removing $($_.Name)"
        Remove-Item -Recurse -Force $_;
    }

    (Get-ChildItem -Path $Path -Directory) | ForEach-Object {
        Remove-Targets -Path (Join-Path $Path $_.Name)
    }
}

Remove-Targets

Write-Host "`nDone." -ForegroundColor Green
