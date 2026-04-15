import 'package:get/get.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/dashboard/domain/gateways/activity_gateway.dart';
import 'package:waternode/features/dashboard/domain/models/task_log_entry.dart';

class DashboardController extends GetxController {
  DashboardController(this._credentialController, this._activityGateway);

  static const batchDelay = Duration(milliseconds: 150);

  final CredentialController _credentialController;
  final ActivityGateway _activityGateway;

  final logs = <TaskLogEntry>[].obs;
  final isSigningIn = false.obs;
  final isDrawing = false.obs;

  int get totalCount => _credentialController.totalCount;
  int get validCount => _credentialController.validCount;
  int get invalidCount => _credentialController.invalidCount;
  int get totalPoints => _credentialController.totalPoints;

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
            addLog('${credential.mobile} $actionName成功');
          } catch (error) {
            addLog('${credential.mobile} $actionName失败: $error', isError: true);
          }
        }),
      );
    }
    await Future.wait(tasks);
    await _credentialController.load();
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
}
