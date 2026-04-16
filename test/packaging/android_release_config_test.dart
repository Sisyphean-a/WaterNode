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
  });

  test('android signing template exists', () {
    expect(File('android/key.properties.example').existsSync(), isTrue);
  });
}
