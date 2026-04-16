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
flutter build apk --release --split-per-abi
```

产物：

- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`

说明：

- Android release 已默认开启 `minify` 与 `shrinkResources`
- 当前应用已改为系统字体栈，不再打包 48M 中文 OTF
- 日常分发优先使用 `app-arm64-v8a-release.apk`

## Windows

1. 构建 release 目录：

```bash
flutter build windows --release
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
