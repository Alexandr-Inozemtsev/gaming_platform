param(
    [Parameter(Mandatory = $true)]
    [string]$UnityProjectPath,

    [Parameter(Mandatory = $true)]
    [string]$RepoSource
)

$ErrorActionPreference = "Stop"

function Step([string]$message) {
    Write-Host "[sync] $message" -ForegroundColor Cyan
}

$tempRoot = Join-Path $env:TEMP ("bigwalker_sync_" + [Guid]::NewGuid().ToString("N"))
$repoRoot = ""

try {
    if (Test-Path $RepoSource) {
        $repoRoot = (Resolve-Path $RepoSource).Path
        Step "Using local repository: $repoRoot"
    }
    else {
        Step "Cloning repository: $RepoSource"
        New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
        git clone --depth 1 $RepoSource $tempRoot | Out-Host
        $repoRoot = $tempRoot
    }

    $sourceScripts = Join-Path $repoRoot "unity/big_walker_starter/Assets/Scripts"
    $targetAssets = Join-Path $UnityProjectPath "Assets"
    $targetScripts = Join-Path $targetAssets "Scripts"

    if (-not (Test-Path $sourceScripts)) {
        throw "Source scripts not found in repository: $sourceScripts"
    }

    if (-not (Test-Path $targetAssets)) {
        throw "Unity Assets folder not found: $targetAssets"
    }

    Step "Cleaning old BigWalker scripts from Unity Assets"
    Get-ChildItem -Path $targetAssets -Recurse -File -Include BigWalker*.cs,BigWalker*.cs.meta |
        Remove-Item -Force -ErrorAction SilentlyContinue

    Step "Recreating target scripts folder: $targetScripts"
    if (Test-Path $targetScripts) {
        Remove-Item -Recurse -Force $targetScripts
    }
    New-Item -ItemType Directory -Path $targetScripts -Force | Out-Null

    Step "Copying starter scripts"
    Copy-Item -Path (Join-Path $sourceScripts "*") -Destination $targetScripts -Recurse -Force

    $targetController = Join-Path $targetScripts "BigWalkerGameController.cs"
    if (-not (Test-Path $targetController)) {
        throw "Target controller not copied: $targetController"
    }

    if (-not (Select-String -Path $targetController -Pattern "Select Players" -Quiet)) {
        throw "Copied controller is not the expected selection-screen version."
    }

    Step "Done. Open Unity -> Assets/Reimport All -> Play"
}
finally {
    if ($tempRoot -and (Test-Path $tempRoot)) {
        Remove-Item -Recurse -Force $tempRoot -ErrorAction SilentlyContinue
    }
}
