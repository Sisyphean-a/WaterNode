import 'package:waternode/features/credentials/domain/models/account_sign_in_state.dart';

class AccountStatus {
  const AccountStatus({
    required this.isValid,
    required this.points,
    this.signInState = AccountSignInState.unknown,
  });

  final bool isValid;
  final int points;
  final AccountSignInState signInState;
}
