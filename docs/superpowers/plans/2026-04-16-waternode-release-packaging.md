# WaterNode Release Packaging Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为 WaterNode 补齐品牌资源、Android release 签名链路和 Windows 安装器，最终产出可安装的 Android APK 与 Windows Setup.exe。

**Architecture:** 使用仓库内统一品牌源文件和本地脚本生成平台图标；Android 直接走 Flutter release 构建并改为固定本地 keystore 签名；Windows 保持 Flutter runner 结构，仅通过 Inno Setup 从 release 目录收集文件生成安装器。

**Tech Stack:** Flutter 3.41、Android Gradle/Kotlin、Windows runner、Python + Pillow、Inno Setup

---

### Task 1: 固化品牌资源生成链路

**Files:**
- Create: `assets/branding/waternode_icon.svg`
- Create: `tool/generate_brand_assets.py`
- Create: `assets/branding/README.md`
- Modify: `windows/runner/resources/app_icon.ico`
- Modify: `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- Modify: `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- Modify: `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- Modify: `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- Modify: `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`
- Test: `test/packaging/brand_assets_test.dart`

- [ ] **Step 1: 写一个失败测试，约束品牌资源入口存在**

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('branding source files exist', () {
    expect(File('assets/branding/waternode_icon.svg').existsSync(), isTrue);
    expect(File('tool/generate_brand_assets.py').existsSync(), isTrue);
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

Run: `flutter test test/packaging/brand_assets_test.dart`
Expected: FAIL with missing branding files.

- [ ] **Step 3: 创建品牌源文件与生成脚本，并生成平台图标**

```python
OUTPUTS = {
    "png": "assets/branding/waternode_icon.png",
    "ico": "windows/runner/resources/app_icon.ico",
    "android": {
        48: "android/app/src/main/res/mipmap-mdpi/ic_launcher.png",
        72: "android/app/src/main/res/mipmap-hdpi/ic_launcher.png",
    },
}
```

- [ ] **Step 4: 重新运行测试确认通过**

Run: `flutter test test/packaging/brand_assets_test.dart`
Expected: PASS

- [ ] **Step 5: 提交前格式化脚本和测试**

Run: `dart format test`
Expected: formatter exits 0

### Task 2: 完成 Android release 包名与签名链路

**Files:**
- Create: `android/key.properties.example`
- Modify: `android/app/build.gradle.kts`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `android/app/src/main/kotlin/com/example/waternode/MainActivity.kt`
- Create: `android/app/src/main/kotlin/com/waternode/app/MainActivity.kt`
- Modify: `.gitignore`
- Test: `test/packaging/android_release_config_test.dart`

- [ ] **Step 1: 写一个失败测试，约束正式应用名和正式包名**

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('android manifest uses WaterNode label', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest.contains('android:label="WaterNode"'), isTrue);
  });

  test('android activity package migrated from example namespace', () {
    expect(File('android/app/src/main/kotlin/com/waternode/app/MainActivity.kt').existsSync(), isTrue);
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

Run: `flutter test test/packaging/android_release_config_test.dart`
Expected: FAIL with old label or old package path.

- [ ] **Step 3: 改造 Android release 配置**

```kotlin
defaultConfig {
    applicationId = "com.waternode.app"
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

- [ ] **Step 4: 增加本地签名模板和忽略规则**

```properties
storeFile=../android/keystore/waternode-release.jks
storePassword=changeit
keyAlias=waternode
keyPassword=changeit
```

- [ ] **Step 5: 重新运行测试确认通过**

Run: `flutter test test/packaging/android_release_config_test.dart`
Expected: PASS

### Task 3: 完成 Windows 程序信息与安装器脚本

**Files:**
- Create: `installer/windows/waternode.iss`
- Create: `installer/windows/README.md`
- Modify: `windows/runner/Runner.rc`
- Test: `test/packaging/windows_installer_config_test.dart`

- [ ] **Step 1: 写一个失败测试，约束 Windows 安装器脚本存在且程序信息已品牌化**

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('windows installer script exists', () {
    expect(File('installer/windows/waternode.iss').existsSync(), isTrue);
  });

  test('runner metadata uses WaterNode branding', () {
    final rc = File('windows/runner/Runner.rc').readAsStringSync();
    expect(rc.contains('VALUE "ProductName", "WaterNode"'), isTrue);
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

Run: `flutter test test/packaging/windows_installer_config_test.dart`
Expected: FAIL with missing installer script or old runner metadata.

- [ ] **Step 3: 新增 Inno Setup 安装脚本并更新 Runner.rc**

```iss
[Setup]
AppName=WaterNode
OutputBaseFilename=WaterNode Setup
DefaultDirName={autopf}\WaterNode
```

- [ ] **Step 4: 重新运行测试确认通过**

Run: `flutter test test/packaging/windows_installer_config_test.dart`
Expected: PASS

### Task 4: 构建发布产物并验证

**Files:**
- Create: `docs/release-packaging.md`
- Modify: `pubspec.yaml`

- [ ] **Step 1: 准备 keystore 并生成 Android release 包**

Run: `flutter build apk --release`
Expected: exit 0 and `build/app/outputs/flutter-apk/app-release.apk` exists.

- [ ] **Step 2: 生成 Windows release 目录**

Run: `flutter build windows --release`
Expected: exit 0 and `build/windows/x64/runner/Release/` exists.

- [ ] **Step 3: 编译安装器**

Run: `iscc installer/windows/waternode.iss`
Expected: exit 0 and `dist/windows/WaterNode Setup.exe` exists.

- [ ] **Step 4: 记录最终打包流程**

```markdown
1. python tool/generate_brand_assets.py
2. flutter build apk --release
3. flutter build windows --release
4. iscc installer/windows/waternode.iss
```

- [ ] **Step 5: 运行完整验证**

Run: `flutter analyze`
Expected: exit 0

Run: `flutter test`
Expected: all tests pass
