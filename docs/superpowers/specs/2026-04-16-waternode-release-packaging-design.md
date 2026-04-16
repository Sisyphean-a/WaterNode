# WaterNode 双平台发布包装设计

## 目标

为 `WaterNode` 补齐 Windows 与 Android 的发布资产链路，交付两类可直接分发给少量用户的安装产物：

- Windows 可安装 `Setup.exe`
- Android 可侧载安装 `release APK`

本次设计同时要求仓库内补齐可重复打包所需的资源、脚本和配置，不接受只产出一次性构建结果的临时方案。

## 交付范围

### Windows

- 程序显示名称统一为 `WaterNode`
- 程序图标替换为正式品牌图标
- 生成可安装、可卸载的安装器
- 安装器创建开始菜单快捷方式与桌面快捷方式
- 安装器输出名称固定为 `WaterNode Setup.exe`

### Android

- 程序显示名称统一为 `WaterNode`
- 包名改为正式值，不再使用 `com.example.*`
- 使用固定本地 keystore 生成 `release APK`
- 启动图标替换为正式品牌图标

### 仓库内必须补齐的文件

- 品牌源文件
- 图标生成脚本
- Windows 安装器脚本
- Android 签名配置模板
- 打包说明

## 非目标

- 不处理应用商店上架要求
- 不接入 Windows 代码签名证书
- 不生成 Android App Bundle
- 不引入远程发布、CI 或自动上传流程

## 品牌与资源策略

品牌方向固定为 `水滴 + 节点`，要求体现“水”和“控制台节点”的组合语义，视觉上偏工具软件而不是消费类图标。

资源组织采用“一份源定义，多平台派生”的方式：

- `assets/branding/waternode_icon.svg`：可编辑的主图源文件
- `assets/branding/waternode_icon.png`：平台图标生成输入位图
- `tool/generate_brand_assets.py`：根据统一图形逻辑生成 PNG、ICO 与 Android launcher 图标

不依赖额外 Flutter 图标插件，避免为了图标生成修改应用运行时依赖。图标生成过程应可在本地独立重复执行。
`assets/branding/` 只存放品牌源文件和生成输入，不作为 Flutter 运行时资源注册进安装包。

## 平台设计

### Android

- 应用名设为 `WaterNode`
- `applicationId` 使用稳定正式值：`com.waternode.app`
- `MainActivity` Kotlin 包路径同步迁移
- `release` 构建不再使用 debug 签名
- 仓库内提供 `android/key.properties.example`
- 本地真实签名信息放在忽略入库的 `android/key.properties`
- keystore 存放在忽略入库的 `android/keystore/waternode-release.jks`

签名设计目标是保证后续继续分发给同一批用户时可以直接升级安装，而不是每次换签名导致只能卸载重装。

### Windows

- 更新 `Runner.rc` 中的产品信息、版权和文件描述
- 保留 Flutter Windows runner 结构，不做不必要重构
- 新增 Inno Setup 脚本生成安装器
- 安装器从 `flutter build windows --release` 的产物目录收集文件
- 安装器写入默认安装目录、开始菜单快捷方式、桌面快捷方式与卸载项

选择 Inno Setup 而不是 MSIX，因为少量用户分发场景下，`.exe` 安装器的接受成本更低，不需要额外处理证书信任。

## 打包链路

### 资源生成

1. 运行品牌资源脚本
2. 更新：
   - `assets/branding/waternode_icon.png`
   - `windows/runner/resources/app_icon.ico`
   - `android/app/src/main/res/mipmap-*/ic_launcher.png`

### Android 打包

1. 准备本地 keystore 与 `android/key.properties`
2. 执行 `flutter build apk --release --split-per-abi --split-debug-info=build/symbols/android`
3. 产出 `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`、
   `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`
4. 同步归档 `build/symbols/android/` 中的 Dart 符号文件，不随 APK 分发

### Windows 打包

1. 执行 `flutter build windows --release --split-debug-info=build/symbols/windows`
2. 使用 Inno Setup 编译安装脚本
3. 产出 `dist/windows/WaterNode Setup.exe`
4. 同步归档 `build/symbols/windows/` 中的 Dart 符号文件，不打进安装器

## 验收标准

### 资源完整性

- 仓库内存在统一品牌源文件
- Android 与 Windows 图标均为正式品牌图标
- Windows 安装器脚本可重复执行

### 安装可用性

- Android `release APK` 可安装
- Windows 安装器可成功安装和卸载
- Windows 安装后可以从桌面快捷方式启动

### 可重复打包

- 新机器只需补本地签名材料和安装器工具，即可按照文档重复打包
- 以后替换图标时只需更新统一源文件并重新执行生成脚本

## 风险与约束

- Android keystore 一旦投入分发，后续必须继续保留，否则无法平滑升级
- Windows 安装器未做代码签名，首次安装可能出现系统安全提示，这是当前分发模型可接受的已知限制
- 本次不处理 iOS、macOS、Linux 与 Web，因为仓库实际交付目标仅为 Android 与 Windows
