# WaterNode External API Endpoints

## Scope

本文档记录的是 WaterNode 当前代码里“真实调用到的外部接口”，不是网关的完整接口清单，也不是历史设计稿。

Base URL:

```text
https://gateway.exiaokang.cn
```

## Shared Response Rules

- 成功码由 `lib/core/network/api_response.dart` 统一判定，默认成功值是字符串 `'200'`
- 若响应 `msg` 非空且 `code != 200`，客户端直接抛出 `AppException(msg)`
- 若是 Dio 层异常，`ApiClient` 会抛出：
  - `AppException('GET <path> failed')`
  - `AppException('POST <path> failed')`

## Shared Header Rules

### Pre-auth Headers

用于发送验证码与短信登录。

| Header           | Value                       |
| ---------------- | --------------------------- |
| `platform-type`  | `CUSTOMER_APP`              |
| `device-id`      | `PQ3A.190605.08171456`      |
| `application-id` | `cn.exiaokang.app.customer` |

### Authorized Headers

由 `DynamicHeaderFactory.buildAuthorizedHeaders()` 根据 Token 动态生成。

| Header          | Source                                      |
| --------------- | ------------------------------------------- |
| `User-Agent`    | 由 `platformType` 决定                      |
| `Platform-Type` | Token payload `platformType`                |
| `Device-Id`     | Token payload `deviceId`                    |
| `Token`         | 当前账号 Token                              |
| `User-Id`       | 仅部分接口需要，来自 Token payload `userId` |

### User-Agent Resolution

| `platformType` | User-Agent            |
| -------------- | --------------------- |
| `CUSTOMER_APP` | `Dart/3.11 (dart:io)` |
| `APPLETS`      | Windows WeChat UA     |

### Extra Headers by Scenario

| Scenario                       | Extra Headers                                   |
| ------------------------------ | ----------------------------------------------- |
| APPLETS 查询积分/账单/签到状态 | `xweb_xhr: 1`、`Content-Type: application/json` |
| 设备列表查询                   | `page-size: 10`、`page-num: 0`                  |
| 账单查询                       | `Page-Num: 0`、`Page-Size: 10`                  |

## Endpoint Index

| Group   | Method | Path                                                   | Client File                |
| ------- | ------ | ------------------------------------------------------ | -------------------------- |
| Auth    | `POST` | `/ids/pub/sms/sendCode`                                | `auth_api.dart`            |
| Auth    | `POST` | `/ids/pub/login/loginRegisterBySmsCode`                | `auth_api.dart`            |
| Profile | `GET`  | `/ids/app/user/findUserInfo`                           | `account_profile_api.dart` |
| Account | `GET`  | `/pay/account/coin/user`                               | `activity_api.dart`        |
| Account | `GET`  | `/marketing/userSgin/consSignDay`                      | `activity_api.dart`        |
| Account | `GET`  | `/marketing/userSgin/signInClick`                      | `activity_api.dart`        |
| Account | `GET`  | `/marketing/app/turntable/luckDraw`                    | `activity_api.dart`        |
| Account | `GET`  | `/pay/user/accountDetail/bean/list`                    | `activity_api.dart`        |
| Devices | `GET`  | `/marketing/app/freeWaterActivityConfig/findOneConfig` | `device_api.dart`          |
| Devices | `GET`  | `/marketing/app/waterDispenser/findByDeviceId`         | `device_api.dart`          |
| Devices | `GET`  | `/marketing/app/waterDispenser/list/inVillage`         | `device_api.dart`          |
| Devices | `GET`  | `/marketing/app/waterDispenser/listPage`               | `device_api.dart`          |
| Devices | `GET`  | `/marketing/app/freeWaterActivity/fetchWaterByScan`    | `device_api.dart`          |

## Auth

### `POST /ids/pub/sms/sendCode`

- Auth: No token, pre-auth headers only
- Request body:

```json
{
  "mobile": "15700000000",
  "businessType": "LOGIN"
}
```

- Success mapping:
  - `response.data.id` -> `smsCodeId`
- Used by:
  - `AuthController.sendCode()`

### `POST /ids/pub/login/loginRegisterBySmsCode`

- Auth: No token, pre-auth headers only
- Request body:

```json
{
  "mobile": "15700000000",
  "smsCode": "123456",
  "smsCodeId": "sms-id-1"
}
```

- Success mapping:
  - `response.data.token` -> `AuthSession.token`
- Follow-up behavior:
  - 客户端立即解析 Token，提取 `platformType`、`deviceId`、`userId`
  - 然后写入本地 `AccountCredential`

## Profile

### `GET /ids/app/user/findUserInfo`

- Auth: Authorized headers
- Query: None
- Success mapping:
  - `response.data.mobile` -> 导入 Token 时的手机号
- Used by:
  - `CredentialController.importToken()`

## Account Status and Batch Actions

### `GET /pay/account/coin/user`

- Auth: Authorized headers + `User-Id`
- Query parameters:

```text
accountType=COIN
userId=<credential.userId>
```

- Special case:
  - 当返回码是 `h009` 时，客户端把账号标记为失效，并返回 `points = 0`
- Success mapping:

| Response field  | Client field           |
| --------------- | ---------------------- |
| `data.totalFee` | `AccountStatus.points` |

### `GET /marketing/userSgin/consSignDay`

- Auth: 与积分查询同一套 headers
- Query: None
- Success mapping:
  - `code == 200 && ok == true` -> `AccountSignInState.completed`
  - 其他成功响应 -> `AccountSignInState.available`
  - 非成功响应 -> `AccountSignInState.unknown`

### `GET /marketing/userSgin/signInClick`

- Auth: Authorized headers + `User-Id`
- Query: None
- Success rule:
  - 仅验证响应码是否为 `200`
- Used by:
  - `DashboardController.runBatchSignIn()`

### `GET /marketing/app/turntable/luckDraw`

- Auth: Authorized headers + `User-Id`
- Query parameters:

```text
townCode=<string>
```

- Current client behavior:
  - 首页/任务页批量抽奖时传空字符串 `''`
- Success rule:
  - 仅验证响应码是否为 `200`

### `GET /pay/user/accountDetail/bean/list`

- Auth: 与积分查询一致，再附加分页 headers
- Query: None
- Extra headers:

```text
Page-Num: 0
Page-Size: 10
```

- Expected payload:
  - `response.data.content` 必须是数组
- Success mapping:

| Response field | Client field                 |
| -------------- | ---------------------------- |
| `amount`       | `AccountBill.amount`         |
| `inOrPay`      | `AccountBill.direction`      |
| `inOrPayDesc`  | `AccountBill.directionLabel` |
| `billType`     | `AccountBill.billType`       |
| `billTypeDesc` | `AccountBill.billTypeLabel`  |
| `createTime`   | `AccountBill.createdAt`      |
| `totalAmount`  | `AccountBill.totalAmount`    |
| `remark`       | `AccountBill.remark`         |

## Device and Water Dispatch

### `GET /marketing/app/freeWaterActivityConfig/findOneConfig`

- Auth: Authorized headers
- Query: None
- Success mapping:

| Response field | Client field                  |
| -------------- | ----------------------------- |
| `id`           | `FreeWaterConfig.id`          |
| `beanValue`    | `FreeWaterConfig.beanValue`   |
| `waterVolume`  | `FreeWaterConfig.waterVolume` |
| `dayLimit`     | `FreeWaterConfig.dayLimit`    |
| `isOn`         | `FreeWaterConfig.isOn`        |
| `desc`         | `FreeWaterConfig.description` |

### `GET /marketing/app/waterDispenser/findByDeviceId`

- Auth: Authorized headers
- Query parameters:

```text
deviceId=<stationId>
```

- Success mapping:

| Response field                        | Client field                      |
| ------------------------------------- | --------------------------------- |
| `id`                                  | `DeviceStation.id`                |
| `deviceName`                          | `DeviceStation.name`              |
| `deviceNum`                           | `DeviceStation.deviceNum`         |
| `address`                             | `DeviceStation.address`           |
| `dispenserType`                       | `DeviceStation.dispenserType`     |
| `dispenserTypeDesc`                   | `DeviceStation.dispenserTypeDesc` |
| `happyTiDeviceStatus`                 | `DeviceStation.status`            |
| `happyTiDeviceStatusDesc`             | `DeviceStation.statusDescription` |
| `latitude` / `longitude` / `distance` | 经纬度与距离                      |

- Online rule:
  - 优先读 `dispenserIsnOline`
  - 若缺失，则以 `happyTiDeviceStatus != OFFLINE` 推断在线状态

### `GET /marketing/app/waterDispenser/list/inVillage`

- Auth: Authorized headers + 设备列表分页 headers
- Query: None
- Region meaning:
  - `in-village`
- Payload contract:
  - `response.data.content` 必须是数组
- Mapping:
  - 每个元素都按 `DeviceStation` 规则映射

### `GET /marketing/app/waterDispenser/listPage`

- Auth: Authorized headers + 设备列表分页 headers
- Query: None
- Region meaning:
  - `default-page`
- Mapping:
  - 与 `list/inVillage` 相同

### `GET /marketing/app/freeWaterActivity/fetchWaterByScan`

- Auth: Authorized headers
- Query parameters:

```text
deviceId=<stationId>
num=<1|2>
```

- Business meaning:
  - `num = 1` -> 7.5L
  - `num = 2` -> 15L

- Success rule:
  - 仅验证响应码是否为 `200`

- Client-side special handling:
  - 如果异常信息中包含“超出每日取水”，客户端会转成更明确的提示：

```text
当前账号当日取水额度已耗尽，可切换其他账号继续操作
```

## Client Mapping Notes

### Token Fields Required by Client

以下字段必须能从 Token payload 解出，否则客户端会在解析阶段直接失败：

| Field          | Usage                     |
| -------------- | ------------------------- |
| `platformType` | Header 与 User-Agent 选择 |
| `deviceId`     | Authorized Header         |
| `userId`       | 积分、签到、抽奖接口      |

### Local Model Written After Login / Import

客户端不会原样保存接口响应，而是统一收敛到 `AccountCredential`：

| Model field    | Source                    |
| -------------- | ------------------------- |
| `mobile`       | 登录入参或 `findUserInfo` |
| `token`        | 登录响应或导入文本        |
| `platformType` | Token payload             |
| `deviceId`     | Token payload             |
| `userId`       | Token payload             |

## Non-goals

本文档不覆盖以下内容：

- 网关上未被当前客户端调用的接口
- 历史接口稿中的未落地设计
- 服务端实现细节
