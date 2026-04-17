# WaterNode GitHub Android 自动发布设计

## 目标

为 `WaterNode` 增加一条由 GitHub Tag 驱动的 Android 自动发布链路，使仓库在推送任意 tag 后可以自动：

- 恢复 Android 正式签名材料
- 构建按 ABI 拆分的 release APK
- 创建公开 GitHub Release
- 生成发布说明并上传 3 个 APK 资产

这条链路服务于“小范围长期分发”的场景，重点是让后续版本可以稳定覆盖安装，而不是每次本地手工打包上传。

## 交付范围

### GitHub Actions 工作流

- 监听任意 tag push
- 在 CI 环境恢复 Android keystore 与 `key.properties`
- 执行现有发布校验与 Android 打包命令
- 创建公开 GitHub Release
- 使用 GitHub 自动生成的 release notes
- 上传 3 个 ABI 拆分 APK

### 仓库文档与模板

- 补充 GitHub Secrets 配置说明
- 补充 tag 发布流程说明
- 保持本地打包与 CI 打包的签名配置结构一致

## 非目标

- 不构建 Windows 安装包
- 不上传 Dart 符号文件
- 不生成 Android App Bundle
- 不接入 Google Play 或其他商店发布
- 不把 keystore 或密码提交进仓库

## 现状约束

- Android release 签名已通过 [android/app/build.gradle.kts](f:/Github/WaterNode/android/app/build.gradle.kts) 读取 `android/key.properties`
- 仓库已提供 [android/key.properties.example](f:/Github/WaterNode/android/key.properties.example) 作为本地签名模板
- [android/.gitignore](f:/Github/WaterNode/android/.gitignore) 已忽略 `key.properties` 与 `*.jks`
- 项目文档已固定 Android 发布命令为 `flutter build apk --release --split-per-abi --split-debug-info=build/symbols/android`

这意味着仓库本身不需要重做签名接入，只需要把本地已有的签名入口延伸到 GitHub Actions。

## 签名材料设计

### 本地保留

签名材料由本机生成并长期保留，至少包括：

- `android/keystore/waternode-release.jks`
- `keyAlias`
- `storePassword`
- `keyPassword`

这套材料是应用升级身份的一部分，GitHub Actions 只使用副本，不作为唯一存档。

### GitHub Secrets

GitHub 仓库配置以下 Secrets：

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

其中 keystore 原文件先在本地转为 base64 文本，再保存到 `ANDROID_KEYSTORE_BASE64`。CI 运行时恢复为临时文件，不进入 git。

## 工作流设计

### 触发条件

- `push.tags: ['*']`

任意 tag 都触发发布，不限定 `v*` 前缀。

### 执行环境

- `ubuntu-latest`

Android 构建与 Release 上传均可在 Linux runner 完成，不需要引入额外 Windows 构建成本。

### 运行步骤

1. 检出仓库
2. 安装 Flutter 与 Java
3. 执行 `flutter pub get`
4. 从 Secrets 恢复 `android/keystore/waternode-release.jks`
5. 生成临时 `android/key.properties`
6. 执行 `flutter test test/packaging`
7. 执行 `flutter build apk --release --split-per-abi --split-debug-info=build/symbols/android`
8. 创建公开 GitHub Release
9. 向 Release 上传：
   - `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
   - `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`
   - `build/app/outputs/flutter-apk/app-x86_64-release.apk`

### Release 行为

- Release 标题使用 tag 名
- Release 状态为公开发布，不是 draft
- Release 说明由 GitHub 自动根据提交生成

## 配置边界

### 仓库中允许存在的内容

- 工作流文件
- `key.properties.example`
- 文档中的 Secrets 名称与配置步骤

### 仓库中禁止存在的内容

- 真实 `key.properties`
- 真实 `.jks`
- 明文密码
- base64 后的 keystore 文本

## 错误处理

- 若任一 Secret 缺失，工作流直接失败，不做 debug 签名回退
- 若 `flutter test test/packaging` 失败，直接阻断发布
- 若 APK 任一产物缺失，Release 创建流程失败

这符合仓库“禁静默降级”的要求，确保配置错误和构建错误会显式暴露。

## 验证策略

### 本地验证

- 保持本地 `android/key.properties` 与 `android/keystore/waternode-release.jks` 可继续手动打包
- 可本地执行：
  - `flutter test test/packaging`
  - `flutter build apk --release --split-per-abi --split-debug-info=build/symbols/android`

### CI 验证

- 使用测试 tag 触发一次 GitHub Actions
- 确认 Release 自动创建成功
- 确认 3 个 APK 均已上传
- 以 `arm64-v8a` APK 为主进行真机安装验证

## 风险与约束

- keystore 丢失会导致后续版本无法平滑覆盖安装
- 任意 tag 都触发发布，误打 tag 会直接生成公开 Release
- `x86_64` APK 主要用于模拟器或极少数设备，但仍随 split 产物一并上传，避免 CI 结果与文档不一致

## 推荐实施顺序

1. 生成正式签名 keystore 与随机密码
2. 更新本地 `android/key.properties`
3. 在 GitHub 仓库录入 4 个 Secrets
4. 增加 GitHub Actions 工作流
5. 更新发布文档
6. 打测试 tag 验证整条链路
