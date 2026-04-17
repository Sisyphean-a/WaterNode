# WaterNode 发布打包说明

## 资源生成

```bash
python tool/generate_brand_assets.py
```

## Android

1. 复制模板：

```bash
copy android\key.properties.example android\key.properties
```

2. 准备本地 keystore：

```bash
keytool -genkeypair -v -keystore android\keystore\waternode-release.jks -alias waternode -keyalg RSA -keysize 2048 -validity 3650
```

3. 构建按 ABI 拆分的小包：

```bash
flutter build apk --release --split-per-abi --split-debug-info=build/symbols/android
```

产物：

- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`
- `build/app/outputs/flutter-apk/app-x86_64-release.apk`

说明：

- Android release 已默认开启 `minify` 与 `shrinkResources`
- 当前应用已改为系统字体栈，不再打包 48M 中文 OTF
- 日常分发优先使用 `app-arm64-v8a-release.apk`
- `app-x86_64-release.apk` 主要用于 x86_64 设备或模拟器验证，归档时也应一并保留
- `build/symbols/android/` 里的 Dart 符号文件不要随包分发，但要和对应 APK 一起归档，便于后续还原堆栈

## GitHub Actions 自动发布 Android

GitHub Actions 工作流位于 `.github/workflows/android-release.yml`，会在推送任意 tag 时自动：

- 从 Secrets 恢复正式签名 keystore
- 生成临时 `android/key.properties`
- 执行 `flutter test test/packaging`
- 执行 `flutter build apk --release --split-per-abi --split-debug-info=build/symbols/android`
- 创建公开 GitHub Release 并自动生成发布说明
- 上传 3 个已签名 APK

需要在仓库 Secrets 中配置：

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

本地可用 PowerShell 生成 `ANDROID_KEYSTORE_BASE64`：

```powershell
[Convert]::ToBase64String(
  [IO.File]::ReadAllBytes('android\keystore\waternode-release.jks')
)
```

Secrets 配好后，推送任意 tag 即可触发自动发布：

```bash
git tag any-tag-name
git push origin any-tag-name
```

## Windows

1. 构建 release 目录：

```bash
flutter build windows --release --split-debug-info=build/symbols/windows
```

2. 编译安装器：

```bash
iscc installer/windows/waternode.iss
```

产物：

- `dist/windows/WaterNode Setup.exe`

说明：

- 安装器使用 `lzma2/ultra64` 高压缩模式
- 默认排除 `.pdb` / `.lib` / `.exp` / `.ilk` 等非运行时文件
- `build/symbols/windows/` 里的 Dart 符号文件不要打进安装器，但需要和安装器版本一起留档

## 发布前校验

先执行：

```bash
flutter test test/packaging
```

这组守护测试会锁定当前体积约束：

- Android 继续使用 `--split-per-abi` 与 `--split-debug-info`
- Android release 继续保持 `minify` / `shrinkResources` 开启
- 仓库继续不打包已移除的 48M 中文 OTF
- `tool/packaging_asset_budget.json` 继续以 `1 MiB` 默认预算监控会进入安装包的资源目录；
  Flutter 侧仅按 `pubspec.yaml` 当前实际注册的 `assets` / `fonts` 目录纳入，避免把
  `assets/branding/` 这类未注册源文件误判为随包资源
- Windows 安装器继续使用 `lzma2/ultra64` 并排除 `.pdb` / `.lib` / `.exp` / `.ilk`
