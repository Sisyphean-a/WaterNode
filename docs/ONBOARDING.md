# WaterNode Onboarding Guide

## 你会接手什么

WaterNode 是一个内部 Flutter 工具应用。它不是面向公众的完整产品，而是围绕“测试账号管理 + 批量任务 + 免费接水控制台”搭起来的运维/测试工作台。

理解这个项目的最快方式，不是先看所有页面，而是先抓住下面三件事：

1. 这是一个纯客户端项目，核心逻辑都在 `lib/`
2. 所有业务数据都来自外部网关 `https://gateway.exiaokang.cn`
3. 本地只存账号凭证，不存业务库

## 第一天应该先读什么

按下面顺序读，最快进入状态：

1. [ARCHITECTURE.md](./ARCHITECTURE.md)
2. `lib/main.dart`
3. `lib/app/dependencies/app_dependencies.dart`
4. `lib/app/bindings/app_binding.dart`
5. `lib/app/presentation/pages/console_shell_page.dart`
6. `lib/features/credentials/application/credential_controller.dart`
7. `lib/features/dashboard/application/dashboard_controller.dart`
8. `lib/features/devices/application/device_controller.dart`
9. [API_ENDPOINTS.md](./API_ENDPOINTS.md)

## 本地运行

### 安装依赖

```bash
flutter pub get
```

### Windows 运行

```bash
flutter run -d windows
```

### Android 运行

```bash
flutter run -d android
```

## 提交前最少验证

```bash
dart format lib test
flutter analyze
flutter test
```

如果你只改了某个模块，至少补一条对应测试并单跑相关测试文件。

## 代码地图

### 壳层

- `lib/app/app.dart`
  应用入口壳。
- `lib/app/bindings/app_binding.dart`
  所有 GetX 依赖注册位置。
- `lib/app/dependencies/app_dependencies.dart`
  生产依赖和测试依赖切换点。
- `lib/app/presentation/pages/console_shell_page.dart`
  控制台骨架，决定侧边栏/底部导航与页面切换。

### 业务层

- `features/auth`
  短信登录、Token 解析。
- `features/credentials`
  账号持久化、备注、Token 导入、状态刷新。
- `features/dashboard`
  首页、批量操作、账单。
- `features/devices`
  设备列表、免费配置、取水。

### 基础设施层

- `core/network/api_client.dart`
  Dio 包装层。
- `core/network/api_response.dart`
  业务响应解码规则。
- `core/network/dynamic_header_factory.dart`
  动态请求头构造器。

## 你最常改到的地方

### 1. 加一个新接口调用

通常要动这几处：

1. `lib/core/network/api_endpoints.dart`
2. 对应 feature 的 `domain/gateways`
3. 对应 feature 的 `infrastructure/*_api.dart`
4. 对应 controller
5. 对应测试

### 2. 调整首页或控制台 UI

通常要动：

1. `lib/features/dashboard/presentation/pages/dashboard_page.dart`
2. `lib/features/dashboard/presentation/widgets/`
3. `test/features/dashboard/presentation/`
4. 如涉及整体布局，还要看 `test/app/console_shell_responsive_test.dart`

### 3. 调整账号状态/持久化逻辑

优先看：

1. `lib/features/credentials/application/credential_controller.dart`
2. `lib/features/credentials/domain/models/account_credential.dart`
3. `lib/features/credentials/infrastructure/hive_account_repository.dart`
4. `test/features/credentials/`

### 4. 调整取水链路

优先看：

1. `lib/features/devices/application/device_controller.dart`
2. `lib/features/devices/infrastructure/device_api.dart`
3. `lib/features/dashboard/presentation/widgets/dispatch_workbench_section.dart`
4. `test/features/devices/`

## 关键事实

### 路由不是多页面导航

GetX 只注册了一个路由 `/dashboard`。首页、日志、账号管理三页切换，实际是在控制台壳里用 `IndexedStack` 做的内部切页。

### 凭证是项目唯一持久化实体

本地 Hive 只保存 `AccountCredential`。积分、签到状态、设备列表、账单、日志都属于运行态，会在刷新时重新拉接口。

### Header 构造很关键

很多外部接口成功与否依赖 Header。不要直接手写散落在各处：

- 登录前：`buildPreAuthHeaders()`
- 登录后：`buildAuthorizedHeaders()`

如果你新增接口，先判断它属于哪类 Header。

### Token 是系统核心输入

项目依赖 Token 中的：

- `platformType`
- `deviceId`
- `userId`

这些字段缺一个，后续接口通常就跑不通。

## 常见调试入口

### 登录失败

先查：

1. `AuthController.smsCodeId`
2. `AuthApi.login()`
3. `TokenPayloadParser.parse()`

### 账号刷新后状态不对

先查：

1. `CredentialController.refreshStatuses()`
2. `ActivityApi.fetchStatus()`
3. `ApiResponse.ensureSuccess()`

### 首页没有设备或无法取水

先查：

1. `DeviceController.prepareWorkbench()`
2. `DeviceController.loadStations()`
3. `DeviceApi.getFreeWaterConfig()`
4. `DeviceApi.getWaterStations()`
5. `DeviceApi.dispenseWater()`

### 账单异常

先查：

1. `DashboardController.loadBills()`
2. `ActivityApi.fetchBills()`
3. `AccountBill` 字段映射

## 测试约定

- 新增控制器行为：优先加 `application` 测试
- 新增接口映射：加 `infrastructure` 测试
- 改 UI 行为：加 `presentation` / `app` Widget Test
- 只修 bug 不补测试，不算完整修复

## 不要误解的点

- 这不是一个有后端源码的全栈仓库
- 这不是一个通用账号系统，而是面向特定业务网关的客户端工具
- 旧的根目录文档已经退休，当前应以 `docs/` 下三份文档为准

## 新成员第一周建议

1. 跑通 Windows 版本
2. 跑一遍全部测试
3. 阅读 `ARCHITECTURE.md` 和 `API_ENDPOINTS.md`
4. 独立跟一遍“导入 Token -> 刷新状态 -> 首页取水”的代码路径
5. 再开始动 UI 或接口逻辑
