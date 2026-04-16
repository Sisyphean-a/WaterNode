import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release packaging guide recommends split ABI android builds', () {
    final guide = File('docs/release-packaging.md').readAsStringSync();

    expect(guide.contains('flutter build apk --release --split-per-abi'), isTrue);
    expect(guide.contains('app-arm64-v8a-release.apk'), isTrue);
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
}
