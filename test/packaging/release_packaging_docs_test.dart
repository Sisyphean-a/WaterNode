import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release packaging guide recommends split ABI android builds', () {
    final guide = File('docs/release-packaging.md').readAsStringSync();

    expect(
      guide.contains('flutter build apk --release --split-per-abi'),
      isTrue,
    );
    expect(guide.contains('app-arm64-v8a-release.apk'), isTrue);
    expect(guide.contains('app-armeabi-v7a-release.apk'), isTrue);
    expect(guide.contains('app-x86_64-release.apk'), isTrue);
  });

  test('release packaging guide stores dart symbols outside release bundles', () {
    final guide = File('docs/release-packaging.md').readAsStringSync();

    expect(
      guide.contains(
        'flutter build apk --release --split-per-abi --split-debug-info=build/symbols/android',
      ),
      isTrue,
    );
    expect(
      guide.contains(
        'flutter build windows --release --split-debug-info=build/symbols/windows',
      ),
      isTrue,
    );
  });

  test('release packaging guide documents size guards before release', () {
    final guide = File('docs/release-packaging.md').readAsStringSync();

    expect(guide.contains('flutter test test/packaging'), isTrue);
    expect(guide.contains('tool/packaging_asset_budget.json'), isTrue);
    expect(guide.contains('1 MiB'), isTrue);
  });

  test('release packaging guide documents github release automation', () {
    final guide = File('docs/release-packaging.md').readAsStringSync();

    expect(guide.contains('GitHub Actions'), isTrue);
    expect(guide.contains('任意 tag'), isTrue);
    expect(guide.contains('ANDROID_KEYSTORE_BASE64'), isTrue);
    expect(guide.contains('ANDROID_KEYSTORE_PASSWORD'), isTrue);
    expect(guide.contains('ANDROID_KEY_ALIAS'), isTrue);
    expect(guide.contains('ANDROID_KEY_PASSWORD'), isTrue);
  });
}
