import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('branding source files exist', () {
    expect(File('assets/branding/waternode_icon.svg').existsSync(), isTrue);
    expect(File('tool/generate_brand_assets.py').existsSync(), isTrue);
  });

  test('platform icon outputs exist', () {
    const androidPaths = <String>[
      'android/app/src/main/res/mipmap-mdpi/ic_launcher.png',
      'android/app/src/main/res/mipmap-hdpi/ic_launcher.png',
      'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png',
      'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png',
      'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png',
    ];

    for (final path in androidPaths) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }

    expect(File('windows/runner/resources/app_icon.ico').existsSync(), isTrue);
  });
}
