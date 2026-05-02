param(
    [Parameter(Mandatory = $true)]
    [string]$UnityProjectPath,

    [string]$SourceRoot = "",

    [switch]$CleanTarget,

    [switch]$CreateBootstrapSceneHint
)

$ErrorActionPreference = "Stop"

function Write-Step([string]$message) {
    Write-Host "[sync] $message" -ForegroundColor Cyan
}

if ([string]::IsNullOrWhiteSpace($SourceRoot)) {
    $SourceRoot = Split-Path -Parent $PSScriptRoot
}

$sourceScripts = Join-Path $SourceRoot "Assets/Scripts"
if (-not (Test-Path $sourceScripts)) {
    throw "Не найдена исходная папка скриптов: $sourceScripts"
}

$targetAssets = Join-Path $UnityProjectPath "Assets"
$targetScripts = Join-Path $targetAssets "Scripts"

if (-not (Test-Path $UnityProjectPath)) {
    throw "Путь Unity проекта не существует: $UnityProjectPath"
}

if (-not (Test-Path $targetAssets)) {
    throw "В Unity проекте нет папки Assets: $targetAssets"
}

Write-Step "Исходник: $sourceScripts"
Write-Step "Назначение: $targetScripts"

if ($CleanTarget -and (Test-Path $targetScripts)) {
    Write-Step "Очистка целевой папки Scripts"
    Remove-Item -Recurse -Force $targetScripts
}

Write-Step "Создание целевой папки"
New-Item -ItemType Directory -Path $targetScripts -Force | Out-Null

Write-Step "Копирование файлов"
Copy-Item -Path (Join-Path $sourceScripts "*") -Destination $targetScripts -Recurse -Force

Write-Step "Готово. Unity автоматически переимпортирует скрипты при фокусе окна."

if ($CreateBootstrapSceneHint) {
    Write-Host ""
    Write-Host "Дальше в Unity:" -ForegroundColor Yellow
    Write-Host "1) Откройте нужную сцену" -ForegroundColor Yellow
    Write-Host "2) Create Empty -> Bootstrap" -ForegroundColor Yellow
    Write-Host "3) Add Component -> BigWalkerSceneBootstrap" -ForegroundColor Yellow
    Write-Host "4) Нажмите Play" -ForegroundColor Yellow
}
