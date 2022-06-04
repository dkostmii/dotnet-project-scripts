try {
  Get-Command dummy -ErrorAction Stop
}
catch {
  Write-Host "Dummy command not found" -ForegroundColor Red
}
