$ErrorActionPreference = "Stop"

$appDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $appDir

Push-Location $appDir
try {
  uv run --python 3.12 `
    --with python-calamine `
    --with python-docx `
    --with pyinstaller `
    pyinstaller `
      --noconfirm `
      --clean `
      --onefile `
      --windowed `
      --name InfectionWeekly `
      --distpath $rootDir `
      --workpath (Join-Path $appDir "build") `
      --specpath $appDir `
      app.py
} finally {
  Pop-Location
}

Write-Host "Built $rootDir\InfectionWeekly.exe"
