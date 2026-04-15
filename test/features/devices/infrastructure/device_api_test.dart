import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/core/errors/app_exception.dart';
import 'package:waternode/core/network/api_client.dart';
import 'package:waternode/core/network/dynamic_header_factory.dart';
import 'package:waternode/features/auth/infrastructure/token_payload_parser.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/devices/infrastructure/device_api.dart';

void main() {
  late _RecordingApiClient client;
  late DeviceApi api;
  late AccountCredential credential;

  setUp(() {
    client = _RecordingApiClient();
    api = DeviceApi(client, DynamicHeaderFactory(TokenPayloadParser()));
    credential = AccountCredential(
      mobile: '15700000000',
      token: _buildToken(),
      platformType: 'CUSTOMER_APP',
      deviceId: 'token-device',
      userId: 'user-1',
      points: 2,
      isValid: true,
    );
  });

  test('loads free water config from real endpoint', () async {
    client.responseForGet['/marketing/app/freeWaterActivityConfig/findOneConfig'] =
        <String, dynamic>{
          'code': '200',
          'data': <String, dynamic>{
            'id': 'config-1',
            'beanValue': 200,
            'waterVolume': '7.50',
            'dayLimit': 2,
            'isOn': true,
          },
        };

    final config = await api.getFreeWaterConfig(credential);

    expect(config.waterVolume, 7.5);
    expect(config.dayLimit, 2);
    expect(
      client.lastGetPath,
      '/marketing/app/freeWaterActivityConfig/findOneConfig',
    );
    expect(client.lastHeaders?['Platform-Type'], 'CUSTOMER_APP');
    expect(client.lastHeaders?['Token'], credential.token);
  });

  test('loads in-village stations with paging headers', () async {
    client.responseForGet['/marketing/app/waterDispenser/list/inVillage'] =
        <String, dynamic>{
          'code': '200',
          'data': <String, dynamic>{
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 'device-1',
                'deviceNum': '864708065296769',
                'deviceName': '冯塘乡丁洼村',
                'address': '超市门口',
                'dispenserIsnOline': true,
                'dispenserType': 'ALL_FREE',
                'dispenserTypeDesc': '全部免费',
                'latitude': 33.596111,
                'longitude': 114.957553,
              },
            ],
          },
        };

    final stations = await api.getWaterStations(
      regionCode: 'in-village',
      credential: credential,
    );

    expect(stations, hasLength(1));
    expect(stations.single.deviceNum, '864708065296769');
    expect(client.lastGetPath, '/marketing/app/waterDispenser/list/inVillage');
    expect(client.lastHeaders?['page-size'], '10');
    expect(client.lastHeaders?['page-num'], '0');
  });

  test('loads device detail by device id', () async {
    client.responseForGet['/marketing/app/waterDispenser/findByDeviceId'] =
        <String, dynamic>{
          'code': '200',
          'data': <String, dynamic>{
            'id': 'device-1',
            'deviceNum': '864708065296769',
            'deviceName': '冯塘乡丁洼村',
            'address': '超市门口',
            'dispenserType': 'ALL_FREE',
            'dispenserTypeDesc': '全部免费',
            'happyTiDeviceStatus': 'OFFLINE',
            'happyTiDeviceStatusDesc': '水箱水量192L',
          },
        };

    final detail = await api.getStationDetail(
      stationId: 'device-1',
      credential: credential,
    );

    expect(detail.status, 'OFFLINE');
    expect(detail.statusDescription, '水箱水量192L');
    expect(client.lastQueryParameters?['deviceId'], 'device-1');
  });

  test('throws explicit business message when fetchWaterByScan fails', () async {
    client.responseForGet['/marketing/app/freeWaterActivity/fetchWaterByScan'] =
        <String, dynamic>{
          'code': '9999',
          'msg': '超出每日取水【2】次数,请明日再试',
          'ok': false,
        };

    await expectLater(
      () => api.dispenseWater(
        stationId: 'device-1',
        quantity: 2,
        credential: credential,
      ),
      throwsA(
        isA<AppException>().having(
          (error) => error.message,
          'message',
          '超出每日取水【2】次数,请明日再试',
        ),
      ),
    );
    expect(client.lastQueryParameters?['deviceId'], 'device-1');
    expect(client.lastQueryParameters?['num'], 2);
  });
}

class _RecordingApiClient extends ApiClient {
  _RecordingApiClient() : super(Dio());

  final Map<String, Map<String, dynamic>> responseForGet =
      <String, Map<String, dynamic>>{};
  String? lastGetPath;
  Map<String, String>? lastHeaders;
  Map<String, dynamic>? lastQueryParameters;

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    lastGetPath = path;
    lastHeaders = headers;
    lastQueryParameters = queryParameters;
    return responseForGet[path] ?? <String, dynamic>{'code': '200'};
  }
}

String _buildToken() {
  final header = base64Url.encode(utf8.encode('{"alg":"none","typ":"JWT"}'));
  final payload = base64Url.encode(
    utf8.encode(
      jsonEncode(<String, String>{
        'platformType': 'CUSTOMER_APP',
        'deviceId': 'token-device',
        'userId': 'user-1',
      }),
    ),
  );

  return '$header.$payload.signature';
}
