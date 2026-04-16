# API Unification Design

**背景**

当前项目已经具备基础分层：`Controller -> Gateway -> *_api.dart -> ApiClient -> Dio`。业务层没有直接依赖 HTTP 细节，这是合理的。现阶段主要问题不在分层缺失，而在于接口路径和通用响应协议处理仍分散在各个 feature API 中，导致重复判断 `code`、重复提取 `data`、重复拼接错误消息。

**目标**

在不推翻现有分层的前提下，统一管理接口路径与后端通用响应协议，降低重复代码，提升后续加接口和改协议时的可维护性。

**非目标**

- 不改 `Gateway` 对外接口
- 不改 `Controller` 调用方式
- 不引入全局巨型 `ApiService`
- 不做泛型仓储或接口注册中心

## 架构方案

保留现有 feature API 作为业务边界，在 `core/network` 下新增两类公共能力：

1. `api_endpoints.dart`
- 只定义接口路径常量
- 按业务动作命名，避免调用方反推 URL 含义

2. `api_response.dart`
- 只处理统一响应协议
- 提供成功校验、`data` 读取、错误消息透传
- 对业务特殊码保留调用方自处理能力

## 文件边界

**新增**

- `lib/core/network/api_endpoints.dart`
  - 存放认证、账号、活动、设备相关 endpoint 常量
- `lib/core/network/api_response.dart`
  - 封装 `code`、`msg`、`data` 读取逻辑

**修改**

- `lib/features/auth/infrastructure/auth_api.dart`
- `lib/features/credentials/infrastructure/account_profile_api.dart`
- `lib/features/dashboard/infrastructure/activity_api.dart`
- `lib/features/devices/infrastructure/device_api.dart`

这些文件继续负责本领域请求与 DTO/领域对象映射，不再重复定义 endpoint 字符串与通用协议解析。

## 数据流

请求流保持不变：

`Controller -> Gateway -> Feature API -> ApiClient -> Dio`

差异在于 Feature API 内部：

- 路径来自 `ApiEndpoints`
- 响应校验和 `data` 读取来自 `ApiResponse`
- 领域映射仍留在各 feature API

## 错误处理

- 统一成功码仍以字符串 `'200'` 为准
- 后端返回非成功码时，优先透传 `msg`
- 若无 `msg`，抛出明确的 `AppException`
- 对 `h009` 这类业务特殊码，不在公共层吞掉，由业务 API 自己判定
- 不增加回退逻辑，不静默降级

## 测试策略

- 新增 `test/core/network/api_response_test.dart`
  - 覆盖成功、失败、缺少 `data`、错误消息透传
- 维持现有 feature API 测试
- 调整已有断言以匹配统一错误消息输出

## 风险与控制

**风险**

- 公共响应层如果设计过宽，会误伤特殊业务码
- 错误消息格式变化可能影响现有测试

**控制**

- 公共层只做最小协议收口，不做业务解释
- `fetchStatus()` 这类特殊码逻辑继续留在业务 API
- 以现有 API 测试作为回归保护

## 预期结果

- 接口路径集中管理
- 通用响应解析集中管理
- Feature API 更聚焦于业务映射
- 现有 controller、gateway、依赖注入不需要调整
