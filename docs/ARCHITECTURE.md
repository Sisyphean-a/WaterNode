# WaterNode Architecture

## Overview

WaterNode 是一个面向 Android 与 Windows 的 Flutter 内部控制台，用来管理测试账号、批量执行签到/抽奖、查看账单，并基于免费接水活动接口完成设备查询与取水指令下发。

项目是单体客户端应用，没有自建后端服务，也没有项目内数据库。所有业务能力都来自外部 HTTP 接口，账号凭证通过本地 Hive 持久化。

## Stack

| Layer | Technology | Version / Source |
| --- | --- | --- |
| UI Runtime | Flutter | 由本地 Flutter SDK 提供 |
| Language | Dart | `sdk: ^3.11.4` |
| State / DI / Routing | GetX | `^4.7.2` |
| HTTP Client | Dio | `^5.9.0` |
| Local Storage | Hive + hive_flutter | `^2.2.3` / `^1.1.0` |
| Token Parsing | jwt_decoder | `^2.0.1` |
| Typography | 系统字体回退栈 | `lib/app/theme/app_theme.dart` |

## Runtime Boundaries

| Boundary | Current Reality |
| --- | --- |
| Supported platforms | Android、Windows |
| Remote gateway | `https://gateway.exiaokang.cn` |
| Persistence | Hive box `account_credentials` |
| Route model | 单路由 `GetMaterialApp` + 控制台内部切页 |
| Environment config | 无 `.env`；网关地址与 Header 常量写在代码里 |

## Directory Structure

```text
lib/
├─ app/                      # 壳层、依赖装配、路由、主题
│  ├─ application/          # 控制台壳层控制器
│  ├─ bindings/             # GetX 依赖注册入口
│  ├─ dependencies/         # 生产/内存依赖装配
│  ├─ presentation/         # 控制台页面与通用容器
│  ├─ routes/               # 应用路由常量与页面声明
│  └─ theme/                # Material 3 主题
├─ core/                     # 错误、网络与请求常量
│  ├─ constants/
│  ├─ errors/
│  └─ network/
└─ features/                 # 按业务域拆分
   ├─ auth/                 # 短信登录与 Token 解析
   ├─ credentials/          # 账号凭证与本地持久化
   ├─ dashboard/            # 首页统计、批量操作、账单
   └─ devices/              # 设备列表、免费配置、取水下发

test/
├─ app/                      # 启动、路由、响应式与主题测试
├─ core/                     # 网络层解析测试
└─ features/                 # 各业务域控制器、接口、页面测试

docs/
├─ ARCHITECTURE.md          # 当前文件
├─ API_ENDPOINTS.md         # 外部接口文档
├─ ONBOARDING.md            # 新成员上手文档
└─ superpowers/             # 设计与计划草稿，不是运行时文档
```

## Application Startup

1. `lib/main.dart`
   `WidgetsFlutterBinding.ensureInitialized()` 后调用 `AppDependencies.createDefault()`。
2. `lib/app/dependencies/app_dependencies.dart`
   初始化 Hive、打开 `account_credentials`、创建 Dio / ApiClient / 各业务 Gateway。
3. `lib/app/app.dart`
   使用 `GetMaterialApp` 启动应用，初始路由固定为 `AppRoutes.dashboard`。
4. `lib/app/bindings/app_binding.dart`
   注册 `ConsoleShellController`、`CredentialController`、`AuthController`、`DashboardController`、`DeviceController`。
5. `lib/app/presentation/pages/console_shell_page.dart`
   根据屏幕宽度切换侧边栏或底部导航，再用 `IndexedStack` 承载三个工作台页面。

## Feature Modules

### 1. Auth

- 控制器：`lib/features/auth/application/auth_controller.dart`
- 接口实现：`lib/features/auth/infrastructure/auth_api.dart`
- 作用：
  - 发送短信验证码
  - 通过验证码登录
  - 解析登录后返回的 Token，提取 `platformType`、`deviceId`、`userId`
- 输出：
  - 登录成功后写入 `AccountCredential`
  - 触发账号列表重载和状态刷新

### 2. Credentials

- 控制器：`lib/features/credentials/application/credential_controller.dart`
- 持久化：
  - 生产：`HiveAccountRepository`
  - 测试：`MemoryAccountRepository`
- 作用：
  - 加载/保存账号凭证
  - 导入已有 Token
  - 更新备注、默认区域、签到状态
  - 刷新账号有效性与积分

### 3. Dashboard

- 控制器：`lib/features/dashboard/application/dashboard_controller.dart`
- 页面：
  - `DashboardPage`：账号统计 + 取水控制台
  - `TaskCenterPage`：批量执行日志、取水记录、账单核对
- 作用：
  - 批量签到
  - 批量抽奖
  - 拉取最近账单
  - 汇总日志输出

### 4. Devices

- 控制器：`lib/features/devices/application/device_controller.dart`
- 接口实现：`lib/features/devices/infrastructure/device_api.dart`
- 作用：
  - 加载免费接水配置
  - 查询“当前村设备”和“更多设备列表”
  - 选择设备并下发 7.5L / 15L 取水指令
  - 记录取水操作日志

## UI Composition

### Navigation Model

- 应用只有一个 GetX 路由：`/dashboard`
- 实际页面切换由 `ConsoleShellController.activeRoute` 驱动
- 桌面端：
  - 左侧折叠侧边栏
  - 右侧内容工作区
- 移动端：
  - 底部导航栏
  - 首页/日志/账号管理三页切换

### Main Screens

| Page | File | Responsibility |
| --- | --- | --- |
| 首页工作台 | `dashboard_page.dart` | 统计卡片、取水控制台 |
| 结果追踪 | `task_center_page.dart` | 任务日志、取水日志、账单核对 |
| 账号管理 | `credential_page.dart` | 刷新、导入、新增、备注维护、Token 复制 |

## Key Flows

### Flow 1: 新增账号

1. 用户在账号管理页打开“新增账户”对话框。
2. `AuthController.sendCode()` 调用短信验证码接口。
3. `AuthController.login()` 使用手机号、验证码、`smsCodeId` 登录。
4. `TokenPayloadParser` 从返回 Token 中提取 `platformType`、`deviceId`、`userId`。
5. `AccountRepository.save()` 持久化凭证。
6. `onCredentialSaved` 回调触发凭证列表重载与状态刷新。

### Flow 2: 导入已有 Token

1. 用户在账号管理页打开 Token 导入对话框。
2. `CredentialController.importToken()` 校验 Token 非空。
3. `TokenPayloadParser` 解析 Token。
4. `AccountProfileApi.fetchMobile()` 远程拉取手机号。
5. 构造 `AccountCredential` 并写入 Hive。
6. 重新加载账号列表。

### Flow 3: 刷新账号状态

1. `CredentialController.refreshStatuses()` 读取本地全部凭证。
2. 逐个调用 `ActivityApi.fetchStatus()`：
   - 查询积分余额
   - 查询签到状态
3. 返回新的 `AccountStatus` 后，更新本地凭证的积分、有效性、签到状态和 `lastCheckedAt`。
4. 批量写回 Hive，并刷新内存态。

### Flow 4: 首页取水

1. `DeviceController.prepareWorkbench()` 先刷新账号状态。
2. 选择默认可用账号，拉取免费接水配置。
3. 同时拉取 `in-village` 与 `default-page` 两类设备列表并合并排序。
4. 用户在首页选择账号和设备，点击 7.5L 或 15L。
5. 弹出确认框后，调用 `fetchWaterByScan`。
6. 成功或失败都写入设备日志；遇到每日额度耗尽时给出明确错误。

## Data Model Summary

### Local Persistent Model

`AccountCredential`

| Field | Meaning |
| --- | --- |
| `mobile` | 手机号，作为 Hive 主键 |
| `token` | 远程接口访问凭证 |
| `platformType` | Token 中解析出的平台类型 |
| `deviceId` | Token 中解析出的设备标识 |
| `userId` | Token 中解析出的用户标识 |
| `points` | 当前积分 |
| `isValid` | 账号是否有效 |
| `remark` | 用户自定义备注 |
| `defaultRegionCode` | 默认设备来源 |
| `signInState` | 签到状态 |
| `lastCheckedAt` | 最近状态刷新时间 |

### Transient Models

- `AccountStatus`：积分、有效性、签到状态
- `AccountBill`：账单条目
- `FreeWaterConfig`：免费接水活动配置
- `DeviceStation`：设备列表与设备详情映射结果
- `TaskLogEntry`：任务/取水日志

## Networking Rules

- 所有请求都通过 `ApiClient` 发出。
- 网络异常统一封装为 `AppException('GET/POST <path> failed')`。
- 业务成功判断统一由 `ApiResponse.ensureSuccess()` 完成，默认成功码为字符串 `'200'`。
- 登录前请求使用固定 Header。
- 登录后请求头由 Token 动态解析，按 `platformType` 自动切换 `User-Agent`。

## Configuration

| File | Responsibility |
| --- | --- |
| `pubspec.yaml` | 依赖、Material 资源与 Dart SDK 约束 |
| `analysis_options.yaml` | lint 规则 |
| `lib/app/theme/app_theme.dart` | 全局主题、字号、圆角、输入框样式 |
| `lib/core/network/api_endpoints.dart` | 外部接口路径常量 |
| `lib/core/constants/header_constants.dart` | 登录前 Header 与 User-Agent 常量 |

## Testing Strategy

- `test/app/`：启动与响应式布局
- `test/core/`：网络响应解析与 Header 行为
- `test/features/*/application/`：控制器行为
- `test/features/*/infrastructure/`：接口映射
- `test/features/*/presentation/`：页面与组件行为

当前项目主要依靠 Widget Test 与纯 Dart 单测，没有集成测试目录。

## Known Constraints

- 网关地址写死在 `AppDependencies.createDefault()`，当前没有多环境切换。
- 外部接口文档以客户端实际调用行为为准，无法代表网关全量能力。
- 项目没有服务端、数据库迁移或独立任务队列。
