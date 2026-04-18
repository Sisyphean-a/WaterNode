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
