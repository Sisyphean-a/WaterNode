import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/credentials/domain/models/account_sign_in_state.dart';
import 'package:waternode/features/credentials/infrastructure/memory_account_repository.dart';
import 'package:waternode/features/dashboard/application/dashboard_controller.dart';
import 'package:waternode/features/dashboard/domain/gateways/activity_gateway.dart';
import 'package:waternode/features/dashboard/domain/models/account_bill.dart';
import 'package:waternode/features/dashboard/domain/models/account_status.dart';
import 'package:waternode/features/dashboard/domain/models/task_log_entry.dart';
import 'package:waternode/features/dashboard/presentation/pages/task_center_page.dart';
import 'package:waternode/features/devices/application/device_controller.dart';
import 'package:waternode/features/devices/domain/gateways/device_gateway.dart';
import 'package:waternode/features/devices/domain/models/device_station.dart';
import 'package:waternode/features/devices/domain/models/free_water_config.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('shows bill timestamp and structured water log details', (
    tester,
  ) async {
    final repository = MemoryAccountRepository();
    await repository.save(
      const AccountCredential(
        mobile: '15700000000',
        token: 'token-1',
        platformType: 'CUSTOMER_APP',
        deviceId: 'device-1',
        userId: 'user-1',
        points: 8,
        isValid: true,
      ),
    );
    final credentialController = CredentialController(
      repository,
      _TaskCenterActivityGateway(),
    );
    await credentialController.load();

    final dashboardController = DashboardController(
      credentialController,
      _TaskCenterActivityGateway(),
    );
    final deviceController = DeviceController(
      credentialController,
      _TaskCenterDeviceGateway(),
    );
    deviceController.logs.assignAll(<TaskLogEntry>[
      TaskLogEntry(
        message: '15700000000 对 冯塘乡丁洼村 取水失败: 当前账号当日取水额度已耗尽',
        createdAt: DateTime(2026, 4, 15, 19, 43, 46),
        isError: true,
      ),
    ]);

    Get.put<DashboardController>(dashboardController);
    Get.put<DeviceController>(deviceController);

    await tester.pumpWidget(
      const GetMaterialApp(home: Scaffold(body: TaskCenterPage())),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('15700000000 对 冯塘乡丁洼村 取水失败: 当前账号当日取水额度已耗尽'),
      findsOneWidget,
    );
    expect(find.textContaining('2026-04-15 19:43'), findsWidgets);
    expect(find.textContaining('2026-04-15 05:26'), findsOneWidget);
    expect(find.text('用户签到 · 收入'), findsOneWidget);
  });
}

class _TaskCenterActivityGateway implements ActivityGateway {
  @override
  Future<AccountStatus> fetchStatus(AccountCredential credential) async {
    return AccountStatus(
      isValid: credential.isValid,
      points: credential.points,
      signInState: AccountSignInState.completed,
    );
  }

  @override
  Future<List<AccountBill>> fetchBills(AccountCredential credential) async {
    return <AccountBill>[
      AccountBill(
        amount: 70,
        direction: 'IN',
        directionLabel: '收入',
        billType: 'SIGN_IN',
        billTypeLabel: '用户签到',
        createdAt: DateTime(2026, 4, 15, 5, 26, 28),
        totalAmount: 10495,
        remark: '签到奖励',
      ),
    ];
  }

  @override
  Future<void> luckDraw(
    AccountCredential credential, {
    required String townCode,
  }) async {}

  @override
  Future<void> signIn(AccountCredential credential) async {}
}

class _TaskCenterDeviceGateway implements DeviceGateway {
  @override
  Future<void> dispenseWater({
    required String stationId,
    required int quantity,
    required AccountCredential credential,
  }) async {}

  @override
  Future<FreeWaterConfig> getFreeWaterConfig(
    AccountCredential credential,
  ) async {
    return const FreeWaterConfig(
      id: 'config-1',
      beanValue: 200,
      waterVolume: 7.5,
      dayLimit: 2,
      isOn: true,
    );
  }

  @override
  Future<DeviceStation> getStationDetail({
    required String stationId,
    required AccountCredential credential,
  }) async {
    return const DeviceStation(
      id: 'device-1',
      name: '冯塘乡丁洼村',
      status: 'ONLINE',
      regionCode: 'in-village',
      deviceNum: '864708065296769',
      address: '超市门口',
      isOnline: true,
      dispenserType: 'ALL_FREE',
      dispenserTypeDesc: '全部免费',
      statusDescription: '水箱水量192L',
    );
  }

  @override
  Future<List<DeviceStation>> getWaterStations({
    required String regionCode,
    required AccountCredential credential,
  }) async {
    return const <DeviceStation>[
      DeviceStation(
        id: 'device-1',
        name: '冯塘乡丁洼村',
        status: 'ONLINE',
        regionCode: 'in-village',
        deviceNum: '864708065296769',
        address: '超市门口',
        isOnline: true,
        dispenserType: 'ALL_FREE',
        dispenserTypeDesc: '全部免费',
        statusDescription: '水箱水量192L',
      ),
    ];
  }
}
