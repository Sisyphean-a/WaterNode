import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/credentials/infrastructure/hive_account_repository.dart';

void main() {
  late Directory tempDirectory;
  late Box<dynamic> box;
  late HiveAccountRepository repository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('waternode_hive_');
    Hive.init(tempDirectory.path);
    box = await Hive.openBox<dynamic>('credentials_test');
    repository = HiveAccountRepository(box);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk('credentials_test');
    await tempDirectory.delete(recursive: true);
  });

  test('persists and reloads credentials', () async {
    const credential = AccountCredential(
      mobile: '15700000000',
      token: 'token-1',
      platformType: 'CUSTOMER_APP',
      deviceId: 'device-1',
      userId: 'user-1',
      points: 12,
      isValid: true,
    );

    await repository.save(credential);

    final credentials = await repository.readAll();

    expect(credentials, hasLength(1));
    expect(credentials.first.mobile, '15700000000');
    expect(credentials.first.points, 12);
  });

  test('updates credential with same mobile instead of duplicating', () async {
    const original = AccountCredential(
      mobile: '15700000000',
      token: 'token-1',
      platformType: 'CUSTOMER_APP',
      deviceId: 'device-1',
      userId: 'user-1',
      points: 12,
      isValid: true,
    );
    const updated = AccountCredential(
      mobile: '15700000000',
      token: 'token-2',
      platformType: 'APPLETS',
      deviceId: 'device-2',
      userId: 'user-2',
      points: 18,
      isValid: false,
    );

    await repository.save(original);
    await repository.save(updated);

    final credentials = await repository.readAll();

    expect(credentials, hasLength(1));
    expect(credentials.single.token, 'token-2');
    expect(credentials.single.points, 18);
    expect(credentials.single.isValid, false);
  });
}
