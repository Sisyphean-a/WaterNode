abstract final class ApiEndpoints {
  static const authSendCode = '/ids/pub/sms/sendCode';
  static const authLoginBySmsCode = '/ids/pub/login/loginRegisterBySmsCode';
  static const accountProfile = '/ids/app/user/findUserInfo';

  static const accountBalance = '/pay/account/coin/user';
  static const accountBillList = '/pay/user/accountDetail/bean/list';
  static const accountSignIn = '/marketing/userSgin/signInClick';
  static const accountSignInState = '/marketing/userSgin/consSignDay';
  static const accountLuckDraw = '/marketing/app/turntable/luckDraw';

  static const freeWaterDispatch =
      '/marketing/app/freeWaterActivity/fetchWaterByScan';
  static const freeWaterConfig =
      '/marketing/app/freeWaterActivityConfig/findOneConfig';
  static const waterStationDetail =
      '/marketing/app/waterDispenser/findByDeviceId';
  static const waterStationInVillage =
      '/marketing/app/waterDispenser/list/inVillage';
  static const waterStationDefaultPage =
      '/marketing/app/waterDispenser/listPage';
}
