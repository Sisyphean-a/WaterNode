import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('android manifest uses WaterNode label', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest.contains('android:label="WaterNode"'), isTrue);
  });

  test('android release manifest declares internet permission', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(
      manifest.contains('android.permission.INTERNET'),
      isTrue,
    );
  });

  test('android build config uses release package id', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();

    expect(gradle.contains('applicationId = "com.waternode.app"'), isTrue);
    expect(gradle.contains('create("release")'), isTrue);
    expect(gradle.contains('isMinifyEnabled = true'), isTrue);
    expect(gradle.contains('isShrinkResources = true'), isTrue);
    expect(
      gradle.contains('signingConfig = signingConfigs.getByName("release")'),
      isTrue,
    );
  });

  test('android activity package migrated from example namespace', () {
    expect(
      File(
        'android/app/src/main/kotlin/com/waternode/app/MainActivity.kt',
      ).existsSync(),
      isTrue,
    );
    expect(
      File(
        'android/app/src/main/kotlin/com/example/waternode/MainActivity.kt',
      ).existsSync(),
      isFalse,
      reason: '旧命名空间文件应在迁移后彻底移除，避免历史包名继续误导维护',
    );
  });

  test('android signing template exists', () {
    expect(File('android/key.properties.example').existsSync(), isTrue);
  });

  test('pubspec does not bundle custom Chinese font assets', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(pubspec.contains("family: NotoSansSC"), isFalse);
    expect(pubspec.contains('fonts/noto_sans_sc/'), isFalse);
  });

  test('repository does not retain removed Noto Sans SC assets', () {
    expect(Directory('fonts/noto_sans_sc').existsSync(), isFalse);
    expect(File('fonts/noto_sans_sc/NotoSansCJKsc-Regular.otf').existsSync(), isFalse);
    expect(File('fonts/noto_sans_sc/NotoSansCJKsc-Medium.otf').existsSync(), isFalse);
    expect(File('fonts/noto_sans_sc/NotoSansCJKsc-Bold.otf').existsSync(), isFalse);
  });
}
