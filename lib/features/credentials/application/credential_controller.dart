import 'package:get/get.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/credentials/domain/repositories/account_repository.dart';
import 'package:waternode/features/dashboard/domain/gateways/activity_gateway.dart';

class CredentialController extends GetxController {
  CredentialController(this._repository, this._activityGateway);

  final AccountRepository _repository;
  final ActivityGateway _activityGateway;

  final credentials = <AccountCredential>[].obs;
  final isRefreshing = false.obs;
  final lastError = RxnString();

  int get totalCount => credentials.length;
  int get validCount => credentials.where((item) => item.isValid).length;
  int get invalidCount => totalCount - validCount;
  int get totalPoints => credentials.fold(0, (sum, item) => sum + item.points);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    credentials.assignAll(await _repository.readAll());
  }

  Future<void> refreshStatuses() async {
    isRefreshing.value = true;
    lastError.value = null;
    try {
      final current = await _repository.readAll();
      final updated = <AccountCredential>[];
      for (final credential in current) {
        final status = await _activityGateway.fetchStatus(credential);
        updated.add(
          credential.copyWith(
            points: status.points,
            isValid: status.isValid,
            lastCheckedAt: DateTime.now(),
          ),
        );
      }
      await _repository.saveAll(updated);
      credentials.assignAll(updated);
    } catch (error) {
      lastError.value = error.toString();
      rethrow;
    } finally {
      isRefreshing.value = false;
    }
  }
}
