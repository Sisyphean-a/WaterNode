import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('architecture guide reflects system font fallback strategy', () {
    final architecture = File('docs/ARCHITECTURE.md').readAsStringSync();

    expect(architecture.contains('| Typography | NotoSansSC |'), isFalse);
    expect(architecture.contains('系统字体回退栈'), isTrue);
  });

  test('superseded typography docs no longer describe bundled Noto Sans SC assets', () {
    const docPaths = <String>[
      'docs/superpowers/specs/2026-04-16-desktop-typography-unification-design.md',
      'docs/superpowers/plans/2026-04-16-desktop-typography-unification.md',
    ];

    for (final path in docPaths) {
      final content = File(path).readAsStringSync();

      expect(content.contains('已废弃'), isTrue, reason: path);
      expect(content.contains('系统字体'), isTrue, reason: path);
      expect(content.contains('fonts/noto_sans_sc/'), isFalse, reason: path);
      expect(content.contains('使用项目内置 `Noto Sans SC`'), isFalse, reason: path);
      expect(content.contains('接入项目内中文字体'), isFalse, reason: path);
    }
  });

  test('release packaging design docs reflect current split packaging flow', () {
    final spec = File(
      'docs/superpowers/specs/2026-04-16-waternode-release-packaging-design.md',
    ).readAsStringSync();
    final plan = File(
      'docs/superpowers/plans/2026-04-16-waternode-release-packaging.md',
    ).readAsStringSync();

    expect(spec.contains('flutter build apk --release --split-per-abi'), isTrue);
    expect(spec.contains('--split-debug-info=build/symbols/android'), isTrue);
    expect(spec.contains('app-arm64-v8a-release.apk'), isTrue);
    expect(spec.contains('打包主位图'), isFalse);
    expect(spec.contains('平台图标生成输入位图'), isTrue);

    expect(
      plan.contains(
        'flutter build apk --release --split-per-abi --split-debug-info=build/symbols/android',
      ),
      isTrue,
    );
    expect(
      plan.contains('flutter build windows --release --split-debug-info=build/symbols/windows'),
      isTrue,
    );
    expect(plan.contains('app-release.apk'), isFalse);
    expect(
      plan.contains(
        '- Modify: `android/app/src/main/kotlin/com/example/waternode/MainActivity.kt`',
      ),
      isFalse,
    );
    expect(
      plan.contains(
        '- Delete: `android/app/src/main/kotlin/com/example/waternode/MainActivity.kt`',
      ),
      isTrue,
    );
  });
}
