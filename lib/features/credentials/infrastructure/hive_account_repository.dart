import 'package:hive/hive.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/credentials/domain/repositories/account_repository.dart';

class HiveAccountRepository implements AccountRepository {
  HiveAccountRepository(this._box);

  static const boxName = 'account_credentials';

  final Box<dynamic> _box;

  @override
  Future<List<AccountCredential>> readAll() async {
    return _box.values
        .map((dynamic item) => AccountCredential.fromMap(item as Map))
        .toList(growable: false);
  }

  @override
  Future<void> save(AccountCredential credential) async {
    await _box.put(credential.mobile, credential.toMap());
  }

  @override
  Future<void> saveAll(List<AccountCredential> credentials) async {
    final entries = <String, Map<String, dynamic>>{};
    for (final credential in credentials) {
      entries[credential.mobile] = credential.toMap();
    }
    await _box.putAll(entries);
  }
}
