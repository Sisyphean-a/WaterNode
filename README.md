# WaterNode

WaterNode 是一个基于 Flutter 的内部测试控制台，面向 Android 和 Windows，当前首期版本包含多账号凭证管理、批量签到/抽奖任务、IoT 终端大厅占位以及动态 Header 网络层。

## 已实现范围

- `GetX + Dio + Hive` 工程骨架
- 控制台首页、终端管理大厅、凭证管理、登录授权页
- 短信验证码发送、验证码登录 API 封装
- 多账号本地持久化与启动加载
- 动态 Header 工厂，按 Token payload 生成 `CUSTOMER_APP` / `APPLETS` 请求头
- 批量签到、批量抽奖任务编排与日志面板
- IoT 终端级联区域选择与显式 `UnimplementedError` 占位

## 运行

```bash
flutter pub get
flutter run -d windows
```

Android 调试可用：

```bash
flutter run -d android
```

## 验证

```bash
dart format lib test
flutter analyze
flutter test
```
