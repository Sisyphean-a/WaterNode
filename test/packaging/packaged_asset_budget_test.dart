import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const budgetPath = 'tool/packaging_asset_budget.json';

  test('packaging asset budget manifest exists and monitors packaged resources', () {
    final budgetFile = File(budgetPath);

    expect(budgetFile.existsSync(), isTrue);
    if (!budgetFile.existsSync()) {
      return;
    }

    final budget = jsonDecode(budgetFile.readAsStringSync()) as Map<String, dynamic>;
    final monitoredDirectories =
        (budget['monitored_directories'] as List<dynamic>).cast<String>();

    expect(budget['default_max_bytes'], isA<int>());
    expect(budget['default_max_bytes'] as int, lessThanOrEqualTo(1024 * 1024));
    expect(
      monitoredDirectories,
      containsAll(<String>[
        'assets/',
        'fonts/',
        'android/app/src/main/res/',
        'windows/runner/resources/',
      ]),
    );
  });

  test('tracked packaged assets stay within declared size budgets', () {
    final budgetFile = File(budgetPath);

    expect(budgetFile.existsSync(), isTrue);
    if (!budgetFile.existsSync()) {
      return;
    }

    final budget = jsonDecode(budgetFile.readAsStringSync()) as Map<String, dynamic>;
    final defaultMaxBytes = budget['default_max_bytes'] as int;
    final monitoredDirectories =
        (budget['monitored_directories'] as List<dynamic>).cast<String>();
    final overrides = ((budget['path_overrides'] as Map?) ?? const <String, dynamic>{})
        .map<String, int>((key, value) => MapEntry(key as String, value as int));

    final gitLsFiles = Process.runSync('git', const ['ls-files']);
    expect(gitLsFiles.exitCode, 0, reason: gitLsFiles.stderr.toString());
    if (gitLsFiles.exitCode != 0) {
      return;
    }

    final trackedFiles = gitLsFiles.stdout
        .toString()
        .split('\n')
        .where((line) => line.isNotEmpty)
        .where((path) => monitoredDirectories.any(path.startsWith))
        .where((path) => File(path).existsSync())
        .toList();

    final violations = <String>[];
    for (final path in trackedFiles) {
      final size = File(path).lengthSync();
      final maxBytes = overrides[path] ?? defaultMaxBytes;
      if (size > maxBytes) {
        violations.add('$path ($size B > $maxBytes B)');
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
