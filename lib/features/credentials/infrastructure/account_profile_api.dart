import 'package:waternode/core/errors/app_exception.dart';
import 'package:waternode/core/network/api_client.dart';
import 'package:waternode/core/network/api_endpoints.dart';
import 'package:waternode/core/network/api_response.dart';
import 'package:waternode/core/network/dynamic_header_factory.dart';
import 'package:waternode/features/credentials/domain/gateways/account_profile_gateway.dart';

class AccountProfileApi implements AccountProfileGateway {
  AccountProfileApi(this._client, this._headerFactory);

  final ApiClient _client;
  final DynamicHeaderFactory _headerFactory;

  @override
  Future<String> fetchMobile(String token) async {
    final response = await _client.get(
      ApiEndpoints.accountProfile,
      headers: _headerFactory.buildAuthorizedHeaders(token: token),
    );
    final data = ApiResponse.readDataMap(response, action: 'findUserInfo');
    final mobile = data['mobile'];
    if (mobile is String && mobile.isNotEmpty) {
      return mobile;
    }
    throw const AppException('findUserInfo payload missing mobile');
  }
}
