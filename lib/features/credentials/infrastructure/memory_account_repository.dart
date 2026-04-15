import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/credentials/domain/repositories/account_repository.dart';

class MemoryAccountRepository implements AccountRepository {
  MemoryAccountRepository([
    Iterable<AccountCredential> initialCredentials =
        const <AccountCredential>[],
  ]) {
    for (final credential in initialCredentials) {
      _storage[credential.mobile] = credential;
    }
  }

  final Map<String, AccountCredential> _storage = <String, AccountCredential>{};

  @override
  Future<List<AccountCredential>> readAll() async {
    return _storage.values.toList(growable: false);
  }

  @override
  Future<void> save(AccountCredential credential) async {
    _storage[credential.mobile] = credential;
  }

  @override
  Future<void> saveAll(List<AccountCredential> credentials) async {
    for (final credential in credentials) {
      _storage[credential.mobile] = credential;
    }
  }
}
