import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('architecture guide reflects system font fallback strategy', () {
    final architecture = File('docs/ARCHITECTURE.md').readAsStringSync();

    expect(architecture.contains('| Typography | NotoSansSC |'), isFalse);
    expect(architecture.contains('系统字体回退栈'), isTrue);
  });
}
