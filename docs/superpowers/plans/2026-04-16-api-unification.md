# API Unification Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在不调整现有业务分层的前提下，统一接口路径常量与通用响应解析逻辑。

**Architecture:** 保留 `Controller -> Gateway -> Feature API -> ApiClient` 结构，在 `core/network` 新增 endpoint 常量和响应解析公共层，再迁移现有 feature API 使用它们。业务特殊码判断仍保留在各 feature API 内部，避免公共协议层过度设计。

**Tech Stack:** Flutter, Dart, GetX, Dio, flutter_test

---

## Chunk 1: 文档与测试基线

### Task 1: 确认测试入口与新增公共测试文件

**Files:**
- Create: `test/core/network/api_response_test.dart`
- Modify: `test/features/credentials/infrastructure/account_profile_api_test.dart`

- [ ] **Step 1: 写失败测试**

```dart
test('ensureSuccess throws backend message when code is not 200', () {
  expect(
    () => ApiResponse.ensureSuccess(
      <String, dynamic>{'code': '500', 'msg': '服务异常'},
      action: 'demo',
    ),
    throwsA(isA<AppException>()),
  );
});
```

- [ ] **Step 2: 运行测试确认失败**

Run: `flutter test test/core/network/api_response_test.dart`
Expected: FAIL，提示 `ApiResponse` 未定义

- [ ] **Step 3: 最小实现后补齐用例**

```dart
abstract final class ApiResponse {
  static void ensureSuccess(...) {}
}
```

- [ ] **Step 4: 运行测试确认通过**

Run: `flutter test test/core/network/api_response_test.dart`
Expected: PASS

- [ ] **Step 5: Git 提交**

按仓库规则，本步骤跳过，除非用户明确要求提交。

## Chunk 2: 公共网络协议层

### Task 2: 新增统一 endpoint 常量

**Files:**
- Create: `lib/core/network/api_endpoints.dart`
- Modify: `test/features/dashboard/infrastructure/activity_api_test.dart`
- Modify: `test/features/devices/infrastructure/device_api_test.dart`

- [ ] **Step 1: 写失败测试**

```dart
expect(ApiEndpoints.accountBalance, '/pay/account/coin/user');
```

- [ ] **Step 2: 运行测试确认失败**

Run: `flutter test test/features/dashboard/infrastructure/activity_api_test.dart`
Expected: FAIL，提示 `ApiEndpoints` 未定义

- [ ] **Step 3: 最小实现**

```dart
abstract final class ApiEndpoints {
  static const accountBalance = '/pay/account/coin/user';
}
```

- [ ] **Step 4: 运行测试确认通过**

Run: `flutter test test/features/dashboard/infrastructure/activity_api_test.dart`
Expected: PASS

- [ ] **Step 5: Git 提交**

按仓库规则，本步骤跳过，除非用户明确要求提交。

### Task 3: 新增统一响应解析

**Files:**
- Create: `lib/core/network/api_response.dart`
- Test: `test/core/network/api_response_test.dart`

- [ ] **Step 1: 写失败测试**

```dart
test('readDataMap returns typed map when response succeeds', () {
  final data = ApiResponse.readDataMap(
    <String, dynamic>{'code': '200', 'data': <String, dynamic>{'id': '1'}},
    action: 'demo',
  );

  expect(data['id'], '1');
});
```

- [ ] **Step 2: 运行测试确认失败**

Run: `flutter test test/core/network/api_response_test.dart`
Expected: FAIL，提示 `readDataMap` 未定义

- [ ] **Step 3: 最小实现**

```dart
abstract final class ApiResponse {
  static void ensureSuccess(...) {}
  static Map<String, dynamic> readDataMap(...) => <String, dynamic>{};
}
```

- [ ] **Step 4: 运行测试确认通过**

Run: `flutter test test/core/network/api_response_test.dart`
Expected: PASS

- [ ] **Step 5: Git 提交**

按仓库规则，本步骤跳过，除非用户明确要求提交。

## Chunk 3: 迁移现有 Feature API

### Task 4: 迁移认证与账号接口

**Files:**
- Modify: `lib/features/auth/infrastructure/auth_api.dart`
- Modify: `lib/features/credentials/infrastructure/account_profile_api.dart`
- Modify: `test/features/credentials/infrastructure/account_profile_api_test.dart`

- [ ] **Step 1: 写失败测试**

```dart
await expectLater(
  () => api.fetchMobile(_buildToken()),
  throwsA(
    isA<AppException>().having((error) => error.message, 'message', '登录失效'),
  ),
);
```

- [ ] **Step 2: 运行测试确认失败**

Run: `flutter test test/features/credentials/infrastructure/account_profile_api_test.dart`
Expected: FAIL，现有实现错误消息不一致

- [ ] **Step 3: 最小实现**

```dart
final data = ApiResponse.readDataMap(response, action: 'findUserInfo');
```

- [ ] **Step 4: 运行测试确认通过**

Run: `flutter test test/features/credentials/infrastructure/account_profile_api_test.dart`
Expected: PASS

- [ ] **Step 5: Git 提交**

按仓库规则，本步骤跳过，除非用户明确要求提交。

### Task 5: 迁移活动与设备接口

**Files:**
- Modify: `lib/features/dashboard/infrastructure/activity_api.dart`
- Modify: `lib/features/devices/infrastructure/device_api.dart`
- Test: `test/features/dashboard/infrastructure/activity_api_test.dart`
- Test: `test/features/devices/infrastructure/device_api_test.dart`

- [ ] **Step 1: 写失败测试**

```dart
expect(client.lastGetPath, ApiEndpoints.freeWaterConfig);
```

- [ ] **Step 2: 运行测试确认失败**

Run: `flutter test test/features/dashboard/infrastructure/activity_api_test.dart test/features/devices/infrastructure/device_api_test.dart`
Expected: FAIL，现有测试未引用公共常量或逻辑未迁移

- [ ] **Step 3: 最小实现**

```dart
final data = ApiResponse.readDataMap(response, action: 'findOneConfig');
```

- [ ] **Step 4: 运行测试确认通过**

Run: `flutter test test/features/dashboard/infrastructure/activity_api_test.dart test/features/devices/infrastructure/device_api_test.dart`
Expected: PASS

- [ ] **Step 5: Git 提交**

按仓库规则，本步骤跳过，除非用户明确要求提交。

## Chunk 4: 全量验证

### Task 6: 运行相关验证

**Files:**
- Verify only

- [ ] **Step 1: 运行网络层相关测试**

Run: `flutter test test/core/network/api_response_test.dart test/features/credentials/infrastructure/account_profile_api_test.dart test/features/dashboard/infrastructure/activity_api_test.dart test/features/devices/infrastructure/device_api_test.dart`
Expected: PASS

- [ ] **Step 2: 运行静态检查**

Run: `flutter analyze`
Expected: PASS

- [ ] **Step 3: 记录结果**

记录通过的命令和未覆盖的风险点。

- [ ] **Step 4: Git 提交**

按仓库规则，本步骤跳过，除非用户明确要求提交。
