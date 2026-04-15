import 'package:waternode/features/credentials/domain/models/account_credential.dart';

abstract interface class AccountRepository {
  Future<List<AccountCredential>> readAll();

  Future<void> save(AccountCredential credential);

  Future<void> saveAll(List<AccountCredential> credentials);
}
