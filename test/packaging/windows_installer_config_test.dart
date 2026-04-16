import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('windows installer script exists', () {
    expect(File('installer/windows/waternode.iss').existsSync(), isTrue);
  });

  test('runner metadata uses WaterNode branding', () {
    final rc = File('windows/runner/Runner.rc').readAsStringSync();

    expect(rc.contains('VALUE "FileDescription", "WaterNode"'), isTrue);
    expect(rc.contains('VALUE "ProductName", "WaterNode"'), isTrue);
  });
}
