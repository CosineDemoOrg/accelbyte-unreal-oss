# AccelByte Cloud Online Subsystem
## Overview
AccelByte Cloud Online Subsystem (**AccelByte Cloud OSS**) is the high-level bridge between Unreal Engine 
and AccelByte services that comprises interfaces that access AccelByte services and its features. 
The AccelByte Cloud OSS is designed to handle higher level logic with asynchronous communication and 
delegates, and is also designed to  be modular by grouping similar service-specific APIs that support features together.
## Supported Unreal Engine
- [ ] Unreal Engine 4.25
- [ ] Unreal Engine 4.26
- [x] Unreal Engine 4.27.x
- [x] Unreal Engine 5.0.x
- [x] Unreal Engine 5.1.x
- [x] Unreal Engine 5.2.x
- [x] Unreal Engine 5.3.x
- [x] Unreal Engine 5.4.x
- [x] Unreal Engine 5.5.x
- [x] Unreal Engine 5.6.x (Beta)

## Dependencies
AccelByte OSS have some dependencies to another Plugins/Modules, such as the following:
1. AccelByte Cloud Unreal Engine SDK ([link](https://github.com/accelbyte/accelbyte-unreal-sdk-plugin)):
   a library that comprises APIs for the game client and game server to send requests to AccelByte services.
2. AccelByte Cloud Network Utilities ([link](https://github.com/AccelByte/accelbyte-unreal-network-utilities)):
   a library that comprises network functionalities to communicate between game clients for P2P networking.

## Build and Install

You can build this plugin from source using Unreal Automation Tool (UAT). The repository includes helper scripts that:
- Fetch external plugin dependencies (AccelByte Unreal SDK and AccelByte Network Utilities)
- Invoke UAT BuildPlugin with the correct parameters

Prerequisites:
- Unreal Engine 4.27 or 5.x installed (from Epic Launcher or source)
- git available on PATH
- Windows PowerShell or a Bash shell (macOS/Linux)

### Quick build (Windows)
```
powershell -ExecutionPolicy Bypass -File scripts/build_plugin.ps1 "C:\Program Files\Epic Games\UE_5.4" "Win64" ".\dist"
```

### Quick build (macOS/Linux)
```
chmod +x scripts/build_plugin.sh
scripts/build_plugin.sh "/Users/you/Library/Application Support/Epic/UnrealEngine/UE_5.4" "Mac" "./dist"
```

Notes:
- The second argument is a comma-separated list of target platforms: Win64, Linux, Mac, Android, IOS.
- If the third argument (output dir) is omitted, artifacts go to `./dist/OnlineSubsystemAccelByte`.
- To pin dependency versions, set environment variables before running:
  - AB_SDK_REPO (default: https://github.com/accelbyte/accelbyte-unreal-sdk-plugin.git)
  - AB_NETUTILS_REPO (default: https://github.com/AccelByte/accelbyte-unreal-network-utilities.git)
  - AB_SDK_REF and AB_NETUTILS_REF to a tag/branch/commit if you need specific versions.

The scripts call:
```
RunUAT BuildPlugin -Plugin=OnlineSubsystemAccelByte.uplugin \
                   -Package=<output dir> \
                   -TargetPlatforms=<platforms> \
                   -AdditionalPluginPaths=<paths to fetched deps>
```

### Installing into a project
After a successful build, copy the packaged folder to your game project:
- Create `YourProject/Plugins/OnlineSubsystemAccelByte/`
- Copy the contents of `dist/OnlineSubsystemAccelByte` into that folder
- Open your project; Unreal will compile/load the plugin. Ensure the following plugins are enabled in your project:
  - Online Subsystem
  - Online Subsystem Utils
  - Online Subsystem Steam/PS/Xbox (as applicable)
  - AccelByte Unreal SDK (automatically handled by the build when using the scripts)
  - AccelByte Network Utilities (automatically handled by the build when using the scripts)

## Documentation
The setup and implementation guideline are available in [our portal](https://docs.accelbyte.io/gaming-services/knowledge-base/sdk-tools/sdk-guides/ags-oss-for-ue/).