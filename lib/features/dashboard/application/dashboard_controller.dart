import 'package:get/get.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';
import 'package:waternode/features/credentials/domain/models/account_sign_in_state.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/dashboard/domain/gateways/activity_gateway.dart';
import 'package:waternode/features/dashboard/domain/models/account_bill.dart';
import 'package:waternode/features/dashboard/domain/models/task_log_entry.dart';

class DashboardController extends GetxController {
  DashboardController(this._credentialController, this._activityGateway);

  static const batchDelay = Duration(milliseconds: 150);

  final CredentialController _credentialController;
  final ActivityGateway _activityGateway;

  final logs = <TaskLogEntry>[].obs;
  final recentBills = <AccountBill>[].obs;
  final isSigningIn = false.obs;
  final isDrawing = false.obs;
  final isLoadingBills = false.obs;
  final selectedBillAccountMobile = RxnString();

  int get totalCount => _credentialController.totalCount;
  int get validCount => _credentialController.validCount;
  int get invalidCount => _credentialController.invalidCount;
  int get totalPoints => _credentialController.totalPoints;
  List<AccountCredential> get validCredentials => _credentialController
      .credentials
      .where((item) => item.isValid)
      .toList(growable: false);

  @override
  void onInit() {
    super.onInit();
    loadBills().catchError((_) {});
  }

  Future<void> runBatchSignIn() async {
    isSigningIn.value = true;
    try {
      await _runBatch(actionName: '签到', runner: _activityGateway.signIn);
    } finally {
      isSigningIn.value = false;
    }
  }

  Future<void> runBatchLuckDraw() async {
    isDrawing.value = true;
    try {
      await _runBatch(
        actionName: '抽奖',
        runner: (credential) =>
            _activityGateway.luckDraw(credential, townCode: ''),
      );
    } finally {
      isDrawing.value = false;
    }
  }

  Future<void> _runBatch({
    required String actionName,
    required Future<void> Function(AccountCredential credential) runner,
  }) async {
    await _credentialController.refreshStatuses();
    final targets = _credentialController.credentials
        .where((item) => item.isValid)
        .toList(growable: false);
    final tasks = <Future<void>>[];
    for (var index = 0; index < targets.length; index++) {
      final credential = targets[index];
      tasks.add(
        Future<void>.delayed(batchDelay * index, () async {
          try {
            await runner(credential);
            if (actionName == '签到') {
              await _credentialController.updateAccountMeta(
                credential,
                signInState: AccountSignInState.success,
              );
            }
            addLog('${credential.mobile} $actionName成功');
          } catch (error) {
            if (actionName == '签到') {
              await _credentialController.updateAccountMeta(
                credential,
                signInState: AccountSignInState.failure,
              );
            }
            addLog('${credential.mobile} $actionName失败: $error', isError: true);
          }
        }),
      );
    }
    await Future.wait(tasks);
    await _credentialController.load();
    await loadBills().catchError((_) {});
  }

  void addLog(String message, {bool isError = false}) {
    logs.insert(
      0,
      TaskLogEntry(
        message: message,
        createdAt: DateTime.now(),
        isError: isError,
      ),
    );
  }

  Future<void> loadBills([AccountCredential? credential]) async {
    final target = credential ?? _resolveDefaultBillAccount();
    if (target == null) {
      recentBills.clear();
      selectedBillAccountMobile.value = null;
      return;
    }

    isLoadingBills.value = true;
    selectedBillAccountMobile.value = target.mobile;
    try {
      recentBills.assignAll(await _activityGateway.fetchBills(target));
    } finally {
      isLoadingBills.value = false;
    }
  }

  Future<void> selectBillAccount(String? mobile) async {
    if (mobile == null) {
      return;
    }
    final target = _credentialController.credentials.firstWhereOrNull(
      (item) => item.mobile == mobile,
    );
    if (target == null) {
      return;
    }
    await loadBills(target);
  }

  AccountCredential? _resolveDefaultBillAccount() {
    final sorted = validCredentials.toList(growable: false)
      ..sort((left, right) => right.points.compareTo(left.points));
    final selected = selectedBillAccountMobile.value;
    if (selected != null) {
      return sorted.firstWhereOrNull((item) => item.mobile == selected);
    }
    return sorted.firstOrNull;
  }
}
