#!/usr/bin/env bash
set -euo pipefail

# Build AccelByte Online Subsystem plugin with its external plugin dependencies.
# This script:
# - Clones required dependency plugins locally (AccelByte Unreal SDK, AccelByte Network Utilities)
# - Invokes Unreal Automation Tool (UAT) BuildPlugin
#
# Prerequisites:
# - Unreal Engine 4.27 or 5.x installed
# - git available in PATH
#
# Usage:
#   scripts/build_plugin.sh &lt;UE_ROOT&gt; [TargetPlatforms] [OutputDir]
#
# Examples:
#   scripts/build_plugin.sh "/Users/me/UnrealEngine/UE_5.3" Win64
#   scripts/build_plugin.sh "C:\Program Files\Epic Games\UE_5.4" "Win64,Linux" "./dist"
#
# Notes:
# - TargetPlatforms is a comma-separated list (Win64,Linux,Mac,Android,IOS).
# - If OutputDir is omitted, it defaults to ./dist/OnlineSubsystemAccelByte.
# - You can override dependency repos via environment variables:
#     AB_SDK_REPO=https://github.com/AccelByte/accelbyte-unreal-sdk-plugin.git
#     AB_NETUTILS_REPO=https://github.com/AccelByte/accelbyte-unreal-network-utilities.git
#   Optionally pin to specific refs:
#     AB_SDK_REF=vX.Y.Z  AB_NETUTILS_REF=vA.B.C
#
# Tested with UE 5.3/5.4. The plugin also supports UE 4.27.

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 &lt;UE_ROOT&gt; [TargetPlatforms] [OutputDir]" >&2
  exit 1
fi

UE_ROOT="$1"
TARGET_PLATFORMS="${2:-Win64}"
OUT_DIR="${3:-$(pwd)/dist/OnlineSubsystemAccelByte}"

# Normalize paths
mkdir -p "$OUT_DIR"

# Resolve UAT
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
  UAT="$UE_ROOT/Engine/Build/BatchFiles/RunUAT.bat"
else
  UAT="$UE_ROOT/Engine/Build/BatchFiles/RunUAT.sh"
fi

if [[ ! -f "$UAT" ]]; then
  echo "Could not find RunUAT at: $UAT" >&2
  exit 1
fi

# Dependency configuration
AB_SDK_REPO="${AB_SDK_REPO:-https://github.com/accelbyte/accelbyte-unreal-sdk-plugin.git}"
AB_NETUTILS_REPO="${AB_NETUTILS_REPO:-https://github.com/AccelByte/accelbyte-unreal-network-utilities.git}"
AB_SDK_REF="${AB_SDK_REF:-}"
AB_NETUTILS_REF="${AB_NETUTILS_REF:-}"

WORK_ROOT="$(pwd)/.build"
DEPS_ROOT="$WORK_ROOT/deps"
PLUGIN_ROOT="$(pwd)"
UPLUGIN_PATH="$PLUGIN_ROOT/OnlineSubsystemAccelByte.uplugin"

rm -rf "$WORK_ROOT"
mkdir -p "$DEPS_ROOT"

echo "Cloning dependencies into $DEPS_ROOT"
git clone --depth 1 "$AB_SDK_REPO" "$DEPS_ROOT/accelbyte-unreal-sdk-plugin"
if [[ -n "$AB_SDK_REF" ]]; then
  (cd "$DEPS_ROOT/accelbyte-unreal-sdk-plugin" &amp;&amp; git fetch --depth 1 origin "$AB_SDK_REF" &amp;&amp; git checkout "$AB_SDK_REF")
fi

git clone --depth 1 "$AB_NETUTILS_REPO" "$DEPS_ROOT/accelbyte-unreal-network-utilities"
if [[ -n "$AB_NETUTILS_REF" ]]; then
  (cd "$DEPS_ROOT/accelbyte-unreal-network-utilities" &amp;&amp; git fetch --depth 1 origin "$AB_NETUTILS_REF" &amp;&amp; git checkout "$AB_NETUTILS_REF")
fi

# Build
echo "Invoking UAT BuildPlugin..."
echo "UE: $UE_ROOT"
echo "Targets: $TARGET_PLATFORMS"
echo "Output: $OUT_DIR"

# UAT expects additional plugin search paths if dependencies are outside Engine/Project
ADD_PATHS="$DEPS_ROOT/accelbyte-unreal-sdk-plugin;$DEPS_ROOT/accelbyte-unreal-network-utilities"

if [[ "$UAT" == *.bat ]]; then
  cmd.exe /c "\"$UAT\" BuildPlugin -Plugin=\"$UPLUGIN_PATH\" -Package=\"$OUT_DIR\" -TargetPlatforms=\"$TARGET_PLATFORMS\" -DisableAutoSDK -StrictIncludes -AdditionalPluginPaths=\"$ADD_PATHS\""
else
  bash "$UAT" BuildPlugin -Plugin="$UPLUGIN_PATH" -Package="$OUT_DIR" -TargetPlatforms="$TARGET_PLATFORMS" -DisableAutoSDK -StrictIncludes -AdditionalPluginPaths="$ADD_PATHS"
fi

echo "Done. Packaged plugin at: $OUT_DIR"
echo "You can now install it into a project by copying the contents of this folder into YourProject/Plugins/OnlineSubsystemAccelByte/"