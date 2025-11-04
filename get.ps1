
Clear-Host

# GitHub config
$repo = "anymount/PecinhasFPS"
$apiUrl = "https://api.github.com/repos/$repo/releases/latest"
$headers = @{
    "User-Agent" = "PecinhasFPS-Fetcher"
    "Accept"     = "application/vnd.github.v3+json"
}

# Use current dir if script folder is not defined
$downloadFolder = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }

# Fetch latest release info
try {
    $release = Invoke-RestMethod -Uri $apiUrl -Headers $headers
}
catch {
    Write-Host "[X] Falha ao contatar a API do GitHub." -ForegroundColor Red
    Write-Host "Pressione qualquer tecla para sair..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    return
}

# Extract tag/version
$tag = $release.tag_name
$versionLabel = $tag -replace "^v", ""  # Remove leading "v" if present

# ASCII art header
$asciiHeader = @"

██████╗ ███████╗ ██████╗██╗███╗   ██╗██╗  ██╗ █████╗ ███████╗    ███████╗██████╗ ███████╗
██╔══██╗██╔════╝██╔════╝██║████╗  ██║██║  ██║██╔══██╗██╔════╝    ██╔════╝██╔══██╗██╔════╝
██████╔╝█████╗  ██║     ██║██╔██╗ ██║███████║███████║███████╗    █████╗  ██████╔╝███████╗
██╔═══╝ ██╔══╝  ██║     ██║██║╚██╗██║██╔══██║██╔══██║╚════██║    ██╔══╝  ██╔═══╝ ╚════██║
██║     ███████╗╚██████╗██║██║ ╚████║██║  ██║██║  ██║███████║    ██║     ██║     ███████║
╚═╝     ╚══════╝ ╚═════╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝    ╚═╝     ╚═╝     ╚══════╝
"@

Write-Host $asciiHeader -ForegroundColor Cyan
Write-Host "Version: v$versionLabel" -ForegroundColor Yellow
Write-Host ""

# Find installer asset
$asset = $release.assets | Where-Object { $_.name -match "^pecinhasfps-.*-setup\.exe$" }

if (-not $asset) {
    Write-Host "[X] Nenhum instalador (.exe) encontrado na última versão." -ForegroundColor Red
    Write-Host "Pressione qualquer tecla para sair..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    return
}

$fileName = $asset.name
$downloadPath = Join-Path $downloadFolder $fileName

Write-Host "[✓] Latest version: $tag" -ForegroundColor Green
Write-Host "[✓] Found installer: $fileName" -ForegroundColor Green
Write-Host "[>] Downloading to: $downloadPath" -ForegroundColor Cyan

# Download the installer
try {
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $downloadPath -UseBasicParsing
    Write-Host "`n[✔] Download complete!" -ForegroundColor Green
}
catch {
    Write-Host "[X] Falha ao baixar o instalador." -ForegroundColor Red
    Write-Host "Pressione qualquer tecla para sair..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    return
}

# Launch installer as admin and delete installer immediately after
Write-Host "[🚀] Launching installer..." -ForegroundColor Magenta
try {
    $process = Start-Process -FilePath $downloadPath -Verb RunAs -PassThru
    $process.WaitForExit()
    Remove-Item -Path $downloadPath -Force
    Write-Host "[🗑️] Deleted installer after installer exited." -ForegroundColor DarkYellow
    Write-Host "[>] Obrigado por usar o Pecinhas FPS!" -ForegroundColor Magenta
}
catch {
    Write-Host "[X] Falha ao executar o instalador ou deletar o arquivo." -ForegroundColor Red
    Write-Host "Pressione qualquer tecla para sair..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    return
}

Write-Host "`nPressione qualquer tecla para sair..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
