# WaterNode GitHub Android Release Automation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为 WaterNode 增加任意 tag 触发的 GitHub Android 自动发布能力，使用正式签名构建 3 个 split APK，并自动创建公开 Release 与发布说明。

**Architecture:** 保持现有 Android `key.properties` 签名入口不变，在 GitHub Actions 中从 Secrets 恢复临时 keystore 和 `key.properties`；用守护测试锁定工作流触发条件、签名 Secrets、Release 行为与文档说明；本地只生成并保留忽略入库的签名文件，不把敏感信息写入仓库。

**Tech Stack:** GitHub Actions、Flutter 3.41、Android Gradle/Kotlin、PowerShell、Dart packaging tests

---

### Task 1: 用测试锁定 GitHub 自动发布契约

**Files:**
- Create: `.github/workflows/android-release.yml`
- Create: `test/packaging/github_release_workflow_test.dart`
- Modify: `test/packaging/release_packaging_docs_test.dart`
- Test: `test/packaging/github_release_workflow_test.dart`
- Test: `test/packaging/release_packaging_docs_test.dart`

- [ ] **Step 1: 写失败测试，约束工作流文件存在且按任意 tag 触发**

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('github android release workflow exists', () {
    expect(File('.github/workflows/android-release.yml').existsSync(), isTrue);
  });

  test('workflow publishes signed split APKs for any tag', () {
    final workflow = File(
      '.github/workflows/android-release.yml',
    ).readAsStringSync();

    expect(workflow.contains("tags:\n      - '*'"), isTrue);
    expect(workflow.contains('ANDROID_KEYSTORE_BASE64'), isTrue);
    expect(workflow.contains('ANDROID_KEYSTORE_PASSWORD'), isTrue);
    expect(workflow.contains('ANDROID_KEY_ALIAS'), isTrue);
    expect(workflow.contains('ANDROID_KEY_PASSWORD'), isTrue);
    expect(
      workflow.contains(
        'flutter build apk --release --split-per-abi --split-debug-info=build/symbols/android',
      ),
      isTrue,
    );
    expect(workflow.contains('generate_release_notes: true'), isTrue);
    expect(workflow.contains('draft: false'), isTrue);
    expect(workflow.contains('app-arm64-v8a-release.apk'), isTrue);
    expect(workflow.contains('app-armeabi-v7a-release.apk'), isTrue);
    expect(workflow.contains('app-x86_64-release.apk'), isTrue);
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

Run: `flutter test test/packaging/github_release_workflow_test.dart`
Expected: FAIL with missing `.github/workflows/android-release.yml`.

- [ ] **Step 3: 扩展发布文档测试，锁定 GitHub Release 和 Secrets 说明**

```dart
test('release packaging guide documents github release automation', () {
  final guide = File('docs/release-packaging.md').readAsStringSync();

  expect(guide.contains('GitHub Actions'), isTrue);
  expect(guide.contains('任意 tag'), isTrue);
  expect(guide.contains('ANDROID_KEYSTORE_BASE64'), isTrue);
  expect(guide.contains('ANDROID_KEYSTORE_PASSWORD'), isTrue);
  expect(guide.contains('ANDROID_KEY_ALIAS'), isTrue);
  expect(guide.contains('ANDROID_KEY_PASSWORD'), isTrue);
});
```

- [ ] **Step 4: 运行文档测试确认失败**

Run: `flutter test test/packaging/release_packaging_docs_test.dart`
Expected: FAIL because `docs/release-packaging.md` does not yet mention GitHub Actions and release secrets.

- [ ] **Step 5: 提交测试改动前格式化**

Run: `dart format test/packaging/github_release_workflow_test.dart test/packaging/release_packaging_docs_test.dart`
Expected: formatter exits 0.

### Task 2: 实现 GitHub Actions Android Release 工作流

**Files:**
- Create: `.github/workflows/android-release.yml`
- Modify: `docs/release-packaging.md`
- Modify: `android/key.properties.example`
- Test: `test/packaging/github_release_workflow_test.dart`
- Test: `test/packaging/release_packaging_docs_test.dart`

- [ ] **Step 1: 新增 GitHub Actions 工作流，恢复签名材料并上传 Release 资产**

```yaml
name: Android Release

on:
  push:
    tags:
      - '*'

permissions:
  contents: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'
      - name: Restore Android keystore
        run: |
          mkdir -p android/keystore
          echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 --decode > android/keystore/waternode-release.jks
      - name: Write key.properties
        run: |
          cat <<'EOF' > android/key.properties
          storeFile=keystore/waternode-release.jks
          storePassword=${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
          keyAlias=${{ secrets.ANDROID_KEY_ALIAS }}
          keyPassword=${{ secrets.ANDROID_KEY_PASSWORD }}
          EOF
      - name: Install dependencies
        run: flutter pub get
      - name: Guard packaging docs and config
        run: flutter test test/packaging
      - name: Build signed split APKs
        run: flutter build apk --release --split-per-abi --split-debug-info=build/symbols/android
      - name: Create GitHub release
        uses: softprops/action-gh-release@v2
        with:
          draft: false
          generate_release_notes: true
          files: |
            build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
            build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
            build/app/outputs/flutter-apk/app-x86_64-release.apk
```

- [ ] **Step 2: 更新签名模板，明确本地与 CI 统一使用同一路径**

```properties
storeFile=keystore/waternode-release.jks
storePassword=replace-with-store-password
keyAlias=waternode
keyPassword=replace-with-key-password
```

- [ ] **Step 3: 更新发布文档，加入 GitHub Actions 自动发布章节**

```markdown
## GitHub 自动发布 Android

1. 在本地准备 `android/keystore/waternode-release.jks`
2. 把 keystore 转成 base64 后填入仓库 Secret `ANDROID_KEYSTORE_BASE64`
3. 录入 `ANDROID_KEYSTORE_PASSWORD`、`ANDROID_KEY_ALIAS`、`ANDROID_KEY_PASSWORD`
4. 推送任意 tag，GitHub Actions 会自动构建 3 个已签名 APK 并创建公开 Release
```

- [ ] **Step 4: 重新运行新增测试确认通过**

Run: `flutter test test/packaging/github_release_workflow_test.dart test/packaging/release_packaging_docs_test.dart`
Expected: PASS.

- [ ] **Step 5: 运行完整打包守护测试**

Run: `flutter test test/packaging`
Expected: PASS.

### Task 3: 生成本地正式签名材料并接入 GitHub Secrets

**Files:**
- Create: `android/keystore/waternode-release.jks` (ignored)
- Create: `android/key.properties` (ignored)

- [ ] **Step 1: 生成随机签名密码并在当前终端保留变量**

Run: 

```powershell
$chars = (48..57 + 65..90 + 97..122 + 35..38 + 42 + 43 + 45 + 61)
$storePassword = -join ($chars | Get-Random -Count 24 | ForEach-Object { [char]$_ })
$keyPassword = -join ($chars | Get-Random -Count 24 | ForEach-Object { [char]$_ })
$keyAlias = 'waternode'
Write-Output "storePassword=$storePassword"
Write-Output "keyPassword=$keyPassword"
Write-Output "keyAlias=$keyAlias"
```

Expected: prints one `storePassword`, one `keyPassword`, and `keyAlias=waternode`.

- [ ] **Step 2: 生成正式签名 keystore**

Run:

```powershell
keytool -genkeypair -v `
  -keystore android\keystore\waternode-release.jks `
  -alias $keyAlias `
  -keyalg RSA `
  -keysize 2048 `
  -validity 3650 `
  -storepass $storePassword `
  -keypass $keyPassword `
  -dname "CN=WaterNode, OU=Open Source, O=WaterNode, L=Shanghai, ST=Shanghai, C=CN"
```

Expected: exit 0 and `android\keystore\waternode-release.jks` exists.

- [ ] **Step 3: 写入本地忽略入库的 key.properties**

Run:

```powershell
@"
storeFile=keystore/waternode-release.jks
storePassword=$storePassword
keyAlias=$keyAlias
keyPassword=$keyPassword
"@ | Set-Content -Path android\key.properties -Encoding ascii
```

Expected: exit 0 and `android\key.properties` exists with four properties.

- [ ] **Step 4: 生成 keystore 的 base64 文本并录入 GitHub Secrets**

Run:

```powershell
$keystoreBase64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes('android\keystore\waternode-release.jks'))
Write-Output "ANDROID_KEYSTORE_BASE64=$keystoreBase64"
Write-Output "ANDROID_KEYSTORE_PASSWORD=$storePassword"
Write-Output "ANDROID_KEY_ALIAS=$keyAlias"
Write-Output "ANDROID_KEY_PASSWORD=$keyPassword"
```

Expected: prints four values that can be copied into GitHub repository secrets.

- [ ] **Step 5: 用本地正式签名材料验证 release 构建**

Run: `flutter build apk --release --split-per-abi --split-debug-info=build/symbols/android`
Expected: exit 0 and `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`,
`build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`,
`build/app/outputs/flutter-apk/app-x86_64-release.apk` exist.

### Task 4: 收尾验证与发布联调

**Files:**
- Modify: `docs/release-packaging.md`
- Modify: `.github/workflows/android-release.yml`

- [ ] **Step 1: 运行格式化，确保测试和文档格式稳定**

Run: `dart format test/packaging`
Expected: formatter exits 0.

- [ ] **Step 2: 运行完整回归验证**

Run: `flutter test`
Expected: all tests pass.

- [ ] **Step 3: 检查工作区，确认没有把 keystore 或密码纳入 git**

Run: `git status --short`
Expected: shows workflow/docs/tests changes, but does not show `android/keystore/waternode-release.jks` because `*.jks` is ignored.

- [ ] **Step 4: 推送仓库改动后，用测试 tag 联调 GitHub Release**

Run:

```bash
git tag test-release-automation
git push origin test-release-automation
```

Expected: GitHub Actions creates a public Release named `test-release-automation` with three APK assets.

- [ ] **Step 5: 真机验证主分发 APK**

Run: install `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` on an Android phone.
Expected: installs successfully and can upgrade the previous build signed by the same keystore.
