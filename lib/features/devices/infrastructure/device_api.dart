import 'package:waternode/core/errors/app_exception.dart';
import 'package:waternode/core/network/api_client.dart';
import 'package:waternode/core/network/dynamic_header_factory.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/devices/domain/gateways/device_gateway.dart';
import 'package:waternode/features/devices/domain/models/device_station.dart';
import 'package:waternode/features/devices/domain/models/free_water_config.dart';

class DeviceApi implements DeviceGateway {
  DeviceApi(this._client, this._headerFactory);

  static const _defaultPageSize = '10';
  static const _defaultPageNum = '0';

  final ApiClient _client;
  final DynamicHeaderFactory _headerFactory;

  @override
  Future<void> dispenseWater({
    required String stationId,
    required int quantity,
    required AccountCredential credential,
  }) async {
    final response = await _client.get(
      '/marketing/app/freeWaterActivity/fetchWaterByScan',
      headers: _buildAuthorizedHeaders(credential),
      queryParameters: <String, dynamic>{
        'deviceId': stationId,
        'num': quantity,
      },
    );
    _ensureSuccess(response);
  }

  @override
  Future<FreeWaterConfig> getFreeWaterConfig(
    AccountCredential credential,
  ) async {
    final response = await _client.get(
      '/marketing/app/freeWaterActivityConfig/findOneConfig',
      headers: _buildAuthorizedHeaders(credential),
    );
    final data = _readDataMap(response);

    return FreeWaterConfig(
      id: _readRequiredString(data, 'id'),
      beanValue: _readRequiredInt(data, 'beanValue'),
      waterVolume: _readRequiredDouble(data, 'waterVolume'),
      dayLimit: _readRequiredInt(data, 'dayLimit'),
      isOn: _readRequiredBool(data, 'isOn'),
      description: data['desc'] as String?,
    );
  }

  @override
  Future<DeviceStation> getStationDetail({
    required String stationId,
    required AccountCredential credential,
  }) async {
    final response = await _client.get(
      '/marketing/app/waterDispenser/findByDeviceId',
      headers: _buildAuthorizedHeaders(credential),
      queryParameters: <String, dynamic>{'deviceId': stationId},
    );

    return _mapStation(_readDataMap(response), regionCode: 'detail');
  }

  @override
  Future<List<DeviceStation>> getWaterStations({
    required String regionCode,
    required AccountCredential credential,
  }) async {
    final response = await _client.get(
      _resolveStationPath(regionCode),
      headers: _buildStationHeaders(credential),
    );
    final data = _readDataMap(response);
    final content = data['content'];
    if (content is! List) {
      throw const AppException('设备列表响应缺少 content 数组');
    }

    return content
        .whereType<Map<String, dynamic>>()
        .map((item) => _mapStation(item, regionCode: regionCode))
        .toList(growable: false);
  }

  Map<String, String> _buildAuthorizedHeaders(AccountCredential credential) {
    return _headerFactory.buildAuthorizedHeaders(token: credential.token);
  }

  Map<String, String> _buildStationHeaders(AccountCredential credential) {
    return <String, String>{
      ..._buildAuthorizedHeaders(credential),
      'page-size': _defaultPageSize,
      'page-num': _defaultPageNum,
    };
  }

  DeviceStation _mapStation(
    Map<String, dynamic> data, {
    required String regionCode,
  }) {
    final onlineFlag = data['dispenserIsnOline'];
    final isOnline = onlineFlag is bool
        ? onlineFlag
        : (data['happyTiDeviceStatus'] as String?) != 'OFFLINE';
    final status =
        data['happyTiDeviceStatus'] as String? ??
        (isOnline ? 'ONLINE' : 'OFFLINE');

    return DeviceStation(
      id: _readRequiredString(data, 'id'),
      name: _readRequiredString(data, 'deviceName'),
      status: status,
      regionCode: regionCode,
      deviceNum: _readRequiredString(data, 'deviceNum'),
      address: data['address'] as String?,
      isOnline: isOnline,
      dispenserType: data['dispenserType'] as String?,
      dispenserTypeDesc: data['dispenserTypeDesc'] as String?,
      statusDescription: data['happyTiDeviceStatusDesc'] as String?,
      latitude: _readOptionalDouble(data['latitude']),
      longitude: _readOptionalDouble(data['longitude']),
      distanceKm: _readOptionalDouble(data['distance']),
    );
  }

  Map<String, dynamic> _readDataMap(Map<String, dynamic> response) {
    _ensureSuccess(response);
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw const AppException('响应数据不是对象结构');
  }

  void _ensureSuccess(Map<String, dynamic> response) {
    final code = response['code']?.toString();
    if (code == '200') {
      return;
    }
    final message = response['msg'] as String?;
    if (message != null && message.isNotEmpty) {
      throw AppException(message);
    }
    throw AppException('设备接口返回异常业务码: $code');
  }

  String _resolveStationPath(String regionCode) {
    switch (regionCode) {
      case 'in-village':
        return '/marketing/app/waterDispenser/list/inVillage';
      case 'default-page':
        return '/marketing/app/waterDispenser/listPage';
      default:
        throw UnsupportedError('不支持的设备列表来源: $regionCode');
    }
  }

  bool _readRequiredBool(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is bool) {
      return value;
    }
    throw AppException('$key 不是 bool');
  }

  double _readRequiredDouble(Map<String, dynamic> data, String key) {
    final value = _readOptionalDouble(data[key]);
    if (value != null) {
      return value;
    }
    throw AppException('$key 不是数字');
  }

  int _readRequiredInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.parse(value);
    }
    throw AppException('$key 不是整数');
  }

  String _readRequiredString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    throw AppException('$key 缺失');
  }

  double? _readOptionalDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String && value.isNotEmpty) {
      return double.parse(value);
    }
    return null;
  }
}
