import 'package:get/get.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/devices/domain/gateways/device_gateway.dart';
import 'package:waternode/features/devices/domain/models/device_station.dart';
import 'package:waternode/features/devices/domain/models/region_option.dart';

class DeviceController extends GetxController {
  DeviceController(this._credentialController, this._deviceGateway);

  final CredentialController _credentialController;
  final DeviceGateway _deviceGateway;

  final regions = <RegionOption>[
    const RegionOption(
      code: 'east',
      name: '华东',
      children: <RegionOption>[
        RegionOption(code: 'east-sh', name: '上海'),
        RegionOption(code: 'east-js', name: '江苏'),
      ],
    ),
    const RegionOption(
      code: 'south',
      name: '华南',
      children: <RegionOption>[RegionOption(code: 'south-gd', name: '广东')],
    ),
  ].obs;

  final selectedParent = Rxn<RegionOption>();
  final selectedChild = Rxn<RegionOption>();
  final stations = <DeviceStation>[].obs;
  final logs = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    selectedParent.value = regions.first;
    selectedChild.value = regions.first.children.first;
    loadStations();
  }

  List<RegionOption> get childOptions =>
      selectedParent.value?.children ?? const <RegionOption>[];

  void selectParent(RegionOption? region) {
    if (region == null) {
      return;
    }
    selectedParent.value = region;
    selectedChild.value = region.children.isEmpty
        ? null
        : region.children.first;
    loadStations();
  }

  void selectChild(RegionOption? region) {
    selectedChild.value = region;
    loadStations();
  }

  void loadStations() {
    final regionCode = selectedChild.value?.code ?? selectedParent.value?.code;
    if (regionCode == null) {
      stations.clear();
      return;
    }
    stations.assignAll(<DeviceStation>[
      DeviceStation(
        id: '$regionCode-01',
        name: '终端 A',
        status: 'ONLINE',
        regionCode: regionCode,
      ),
      DeviceStation(
        id: '$regionCode-02',
        name: '终端 B',
        status: 'OFFLINE',
        regionCode: regionCode,
      ),
    ]);
  }

  Future<void> sendCommand(DeviceStation station) async {
    final credential = _findDispatchCredential();
    try {
      await _deviceGateway.dispenseWater(
        stationId: station.id,
        volume: 1,
        credential: credential,
      );
      logs.insert(0, '${station.name} 指令下发成功');
    } catch (error) {
      logs.insert(0, '${station.name} 指令下发失败: $error');
      rethrow;
    }
  }

  AccountCredential _findDispatchCredential() {
    return _credentialController.credentials.firstWhere(
      (item) => item.isValid && item.points > 0,
      orElse: () => throw StateError('没有可用的有效积分账号'),
    );
  }
}
