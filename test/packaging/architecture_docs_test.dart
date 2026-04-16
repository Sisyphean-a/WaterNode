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
}
