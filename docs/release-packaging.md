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

3. 构建：

```bash
flutter build apk --release
```

产物：

- `build/app/outputs/flutter-apk/app-release.apk`

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
