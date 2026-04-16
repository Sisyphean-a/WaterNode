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
import 'package:waternode/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:waternode/features/devices/application/device_controller.dart';
import 'package:waternode/features/devices/domain/gateways/device_gateway.dart';
import 'package:waternode/features/devices/domain/models/device_station.dart';
import 'package:waternode/features/devices/domain/models/free_water_config.dart';

void main() {
  tearDown(Get.reset);

  testWidgets(
    'shows remark or last four digits for account labels on dashboard',
    (tester) async {
      final repository = MemoryAccountRepository();
      await repository.save(
        const AccountCredential(
          mobile: '157000006427',
          token: 'token-1',
          platformType: 'CUSTOMER_APP',
          deviceId: 'device-1',
          userId: 'user-1',
          points: 6,
          isValid: true,
        ),
      );
      await repository.save(
        const AccountCredential(
          mobile: '15800000000',
          token: 'token-2',
          platformType: 'CUSTOMER_APP',
          deviceId: 'device-2',
          userId: 'user-2',
          points: 3,
          isValid: true,
          remark: '家里',
        ),
      );
      final credentialController = CredentialController(
        repository,
        _DashboardActivityGateway(),
      );
      await credentialController.load();
      final dashboardController = DashboardController(
        credentialController,
        _DashboardActivityGateway(),
      );
      final gateway = _DashboardDeviceGateway();
      final deviceController = DeviceController(credentialController, gateway);
      await deviceController.prepareWorkbench();
      Get.put<CredentialController>(credentialController);
      Get.put<DashboardController>(dashboardController);
      Get.put<DeviceController>(deviceController);

      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: DashboardPage())),
      );
      await tester.pumpAndSettle();

      final accountTop = tester.getTopLeft(find.text('有效账号数')).dy;
      final pointsTop = tester.getTopLeft(find.text('总可用积分')).dy;
      expect((accountTop - pointsTop).abs(), lessThan(8));
      expect(find.text('尾号6427'), findsWidgets);

      await tester.tap(find.byKey(const Key('workbench-account-select')));
      await tester.pumpAndSettle();

      expect(find.text('家里'), findsOneWidget);
      expect(find.text('157000006427'), findsNothing);
      expect(find.text('15800000000'), findsNothing);
    },
  );

  testWidgets(
    'shows unified station selector and confirms before sending water',
    (tester) async {
      final repository = MemoryAccountRepository(<AccountCredential>[
        const AccountCredential(
          mobile: '157000006427',
          token: 'token-1',
          platformType: 'CUSTOMER_APP',
          deviceId: 'device-1',
          userId: 'user-1',
          points: 6,
          isValid: true,
        ),
      ]);
      final credentialController = CredentialController(
        repository,
        _DashboardActivityGateway(),
      );
      await credentialController.load();
      final dashboardController = DashboardController(
        credentialController,
        _DashboardActivityGateway(),
      );
      final gateway = _DashboardDeviceGateway();
      final deviceController = DeviceController(credentialController, gateway);
      await deviceController.prepareWorkbench();
      Get.put<CredentialController>(credentialController);
      Get.put<DashboardController>(dashboardController);
      Get.put<DeviceController>(deviceController);

      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: DashboardPage())),
      );
      await tester.pumpAndSettle();

      expect(find.text('设备列表'), findsNothing);
      expect(find.text('设备终端'), findsOneWidget);
      expect(find.byKey(const Key('workbench-source-select')), findsNothing);
      expect(find.textContaining('目标：'), findsNothing);
      expect(find.text('7.5L'), findsOneWidget);
      expect(find.text('15L'), findsOneWidget);
      expect(find.text('取水 7.5L'), findsNothing);
      expect(find.text('取水 15L'), findsNothing);
      expect(find.byIcon(Icons.water_drop_outlined), findsOneWidget);
      expect(find.byIcon(Icons.water_drop_rounded), findsOneWidget);
      final smallButtonWidth = tester
          .getSize(find.byKey(const Key('water-action-7.5')))
          .width;
      final largeButtonWidth = tester
          .getSize(find.byKey(const Key('water-action-15')))
          .width;
      expect((smallButtonWidth - largeButtonWidth).abs(), lessThan(2));

      expect(gateway.lastDispenseQuantity, isNull);

      await tester.tap(find.byKey(const Key('water-action-7.5')));
      await tester.pumpAndSettle();

      expect(find.text('确认取水'), findsOneWidget);
      expect(find.text('7.5L'), findsWidgets);
      expect(gateway.lastDispenseQuantity, isNull);

      await tester.tap(find.widgetWithText(FilledButton, '确认'));
      await tester.pumpAndSettle();

      expect(gateway.lastDispenseQuantity, 1);
      expect(find.text('一键自动化'), findsNothing);
    },
  );
}

class _DashboardActivityGateway implements ActivityGateway {
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
    return const <AccountBill>[];
  }

  @override
  Future<void> luckDraw(
    AccountCredential credential, {
    required String townCode,
  }) async {}

  @override
  Future<void> signIn(AccountCredential credential) async {}
}

class _DashboardDeviceGateway implements DeviceGateway {
  int? lastDispenseQuantity;

  @override
  Future<void> dispenseWater({
    required String stationId,
    required int quantity,
    required AccountCredential credential,
  }) async {
    lastDispenseQuantity = quantity;
  }

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
      isOnline: true,
      dispenserType: 'ALL_FREE',
      dispenserTypeDesc: '全部免费',
    );
  }

  @override
  Future<List<DeviceStation>> getWaterStations({
    required String regionCode,
    required AccountCredential credential,
  }) async {
    return <DeviceStation>[
      DeviceStation(
        id: '$regionCode-1',
        name: '冯塘乡丁洼村',
        status: 'ONLINE',
        regionCode: regionCode,
        deviceNum: '864708065296769',
        isOnline: true,
        dispenserType: 'ALL_FREE',
        dispenserTypeDesc: '全部免费',
      ),
      DeviceStation(
        id: '$regionCode-2',
        name: '卫贤姜含珠',
        status: 'ONLINE',
        regionCode: regionCode,
        deviceNum: '865096063551420',
        isOnline: true,
        dispenserType: 'ALL_FREE',
        dispenserTypeDesc: '全部免费',
      ),
    ];
  }
}
