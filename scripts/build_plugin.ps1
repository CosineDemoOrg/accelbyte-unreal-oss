Param(
  [Parameter(Mandatory=$true)]
  [string]$UERoot,
  [string]$TargetPlatforms = "Win64",
  [string]$OutputDir = ""
)

# Build AccelByte Online Subsystem plugin with its external plugin dependencies on Windows.
# Usage:
#   powershell -ExecutionPolicy Bypass -File scripts/build_plugin.ps1 "C:\Program Files\Epic Games\UE_5.4" "Win64,Linux" ".\dist"
#
# Optional environment variables to override dependency repos/refs:
#   $env:AB_SDK_REPO = "https://github.com/accelbyte/accelbyte-unreal-sdk-plugin.git"
#   $env:AB_NETUTILS_REPO = "https://github.com/AccelByte/accelbyte-unreal-network-utilities.git"
#   $env:AB_SDK_REF = "vx.y.z"
#   $env:AB_NETUTILS_REF = "va.b.c"

$ErrorActionPreference = "Stop"

if (-not $OutputDir -or $OutputDir -eq "") {
  $OutputDir = Join-Path (Get-Location) "dist\OnlineSubsystemAccelByte"
}
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$UAT = Join-Path $UERoot "Engine\Build\BatchFiles\RunUAT.bat"
if (-not (Test-Path $UAT)) {
  Write-Error "Could not find RunUAT at: $UAT"
}

$WorkRoot = Join-Path (Get-Location) ".build"
$DepsRoot = Join-Path $WorkRoot "deps"
$PluginRoot = (Get-Location)
$UPluginPath = Join-Path $PluginRoot "OnlineSubsystemAccelByte.uplugin"

if (Test-Path $WorkRoot) { Remove-Item -Recurse -Force $WorkRoot }
New-Item -ItemType Directory -Force -Path $DepsRoot | Out-Null

$ABSDKRepo = if ($env:AB_SDK_REPO) { $env:AB_SDK_REPO } else { "https://github.com/accelbyte/accelbyte-unreal-sdk-plugin.git" }
$ABNetRepo = if ($env:AB_NETUTILS_REPO) { $env:AB_NETUTILS_REPO } else { "https://github.com/AccelByte/accelbyte-unreal-network-utilities.git" }
$ABSDKRef = $env:AB_SDK_REF
$ABNetRef = $env:AB_NETUTILS_REF

Write-Host "Cloning dependencies into $DepsRoot"
git clone --depth 1 $ABSDKRepo (Join-Path $DepsRoot "accelbyte-unreal-sdk-plugin")
if ($ABSDKRef) {
  Push-Location (Join-Path $DepsRoot "accelbyte-unreal-sdk-plugin")
  git fetch --depth 1 origin $ABSDKRef
  git checkout $ABSDKRef
  Pop-Location
}

git clone --depth 1 $ABNetRepo (Join-Path $DepsRoot "accelbyte-unreal-network-utilities")
if ($ABNetRef) {
  Push-Location (Join-Path $DepsRoot "accelbyte-unreal-network-utilities")
  git fetch --depth 1 origin $ABNetRef
  git checkout $ABNetRef
  Pop-Location
}

$AdditionalPluginPaths = (Join-Path $DepsRoot "accelbyte-unreal-sdk-plugin") + ";" + (Join-Path $DepsRoot "accelbyte-unreal-network-utilities")

Write-Host "Invoking UAT BuildPlugin..."
Write-Host "UE: $UERoot"
Write-Host "Targets: $TargetPlatforms"
Write-Host "Output: $OutputDir"

& $UAT BuildPlugin -Plugin="$UPluginPath" -Package="$OutputDir" -TargetPlatforms="$TargetPlatforms" -DisableAutoSDK -StrictIncludes -AdditionalPluginPaths="$AdditionalPluginPaths"
if ($LASTEXITCODE -ne 0) {
  throw "BuildPlugin failed with exit code $LASTEXITCODE"
}

Write-Host "Done. Packaged plugin at: $OutputDir"
Write-Host "You can now install it into a project by copying the contents into YourProject\Plugins\OnlineSubsystemAccelByte\"