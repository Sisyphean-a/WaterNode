import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/dashboard/domain/models/account_bill.dart';
import 'package:waternode/features/dashboard/domain/models/account_status.dart';

abstract interface class ActivityGateway {
  Future<AccountStatus> fetchStatus(AccountCredential credential);

  Future<List<AccountBill>> fetchBills(AccountCredential credential);

  Future<void> signIn(AccountCredential credential);

  Future<void> luckDraw(
    AccountCredential credential, {
    required String townCode,
  });
}
