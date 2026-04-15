# WaterNode Console Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 搭建 WaterNode Flutter 测试控制台首期版本，交付账号管理、批量任务和 IoT 占位页面。

**Architecture:** 使用 `GetX + Dio + Hive` 分层实现。通过统一 Header 工厂解析 Token 生成请求头，控制器只负责编排流程与更新状态，存储与网络实现通过接口注入。

**Tech Stack:** Flutter, Dart, GetX, Dio, Hive, hive_flutter, jwt_decoder, flutter_test

---

## Chunk 1: Project Bootstrap

### Task 1: Scaffold Flutter app and dependencies

**Files:**
- Create: `pubspec.yaml`
- Create: `lib/main.dart`
- Create: `lib/app/app.dart`
- Create: `lib/app/bindings/app_binding.dart`
- Create: `lib/app/routes/app_pages.dart`
- Create: `lib/app/routes/app_routes.dart`

- [ ] **Step 1: Create the Flutter project skeleton**

Run: `flutter create .`
Expected: Flutter 工程文件生成成功

- [ ] **Step 2: Add required dependencies**

Add: `get`, `dio`, `hive`, `hive_flutter`, `path_provider`, `jwt_decoder`

- [ ] **Step 3: Write a failing widget test for app bootstrap**

Test file: `test/app/app_bootstrap_test.dart`

```dart
testWidgets('boots into dashboard shell', (tester) async {
  await tester.pumpWidget(const WaterNodeApp());
  expect(find.text('控制台首页'), findsOneWidget);
});
```

- [ ] **Step 4: Run test to verify it fails**

Run: `flutter test test/app/app_bootstrap_test.dart`
Expected: FAIL because app shell does not exist yet

- [ ] **Step 5: Implement minimal app shell and routes**

Create `WaterNodeApp` and initial named route mapping.

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/app/app_bootstrap_test.dart`
Expected: PASS

## Chunk 2: Core Infrastructure

### Task 2: Implement token payload parsing and dynamic headers

**Files:**
- Create: `lib/core/constants/header_constants.dart`
- Create: `lib/core/errors/app_exception.dart`
- Create: `lib/features/auth/domain/models/token_payload.dart`
- Create: `lib/features/auth/infrastructure/token_payload_parser.dart`
- Create: `lib/core/network/dynamic_header_factory.dart`
- Test: `test/core/network/dynamic_header_factory_test.dart`

- [ ] **Step 1: Write failing tests for token parsing and header generation**

```dart
test('builds customer app headers from token payload', () {
  final headers = factory.buildAuthorizedHeaders(customerToken);
  expect(headers['Platform-Type'], 'CUSTOMER_APP');
  expect(headers['Device-Id'], 'device-1');
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/network/dynamic_header_factory_test.dart`
Expected: FAIL because parser/factory not implemented

- [ ] **Step 3: Implement parser and header factory**

Support `CUSTOMER_APP` and `APPLETS` only. Unknown platform throws explicit exception.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/network/dynamic_header_factory_test.dart`
Expected: PASS

### Task 3: Implement API client and local storage abstractions

**Files:**
- Create: `lib/core/network/api_client.dart`
- Create: `lib/features/credentials/domain/models/account_credential.dart`
- Create: `lib/features/credentials/domain/repositories/account_repository.dart`
- Create: `lib/features/credentials/infrastructure/hive_account_repository.dart`
- Create: `lib/features/auth/infrastructure/auth_api.dart`
- Create: `lib/features/dashboard/infrastructure/activity_api.dart`
- Create: `lib/features/devices/infrastructure/device_api.dart`
- Test: `test/features/credentials/infrastructure/hive_account_repository_test.dart`

- [ ] **Step 1: Write failing repository persistence test**
- [ ] **Step 2: Run test to verify it fails**
- [ ] **Step 3: Implement Hive-backed repository and API abstractions**
- [ ] **Step 4: Run test to verify it passes**

## Chunk 3: Authentication and Credential Management

### Task 4: Implement auth flow

**Files:**
- Create: `lib/features/auth/application/auth_controller.dart`
- Create: `lib/features/auth/presentation/pages/auth_page.dart`
- Create: `lib/features/auth/presentation/widgets/auth_form.dart`
- Test: `test/features/auth/application/auth_controller_test.dart`
- Test: `test/features/auth/presentation/auth_page_test.dart`

- [ ] **Step 1: Write failing tests for send-code and login flow**
- [ ] **Step 2: Run tests to verify they fail**
- [ ] **Step 3: Implement controller and auth page**
- [ ] **Step 4: Run tests to verify they pass**

### Task 5: Implement credential list and startup heartbeat

**Files:**
- Create: `lib/features/credentials/application/credential_controller.dart`
- Create: `lib/features/credentials/presentation/pages/credential_page.dart`
- Create: `lib/features/credentials/presentation/widgets/credential_card.dart`
- Test: `test/features/credentials/application/credential_controller_test.dart`
- Test: `test/features/credentials/presentation/credential_page_test.dart`

- [ ] **Step 1: Write failing tests for loading credentials and refresh status**
- [ ] **Step 2: Run tests to verify they fail**
- [ ] **Step 3: Implement controller, page, and startup refresh**
- [ ] **Step 4: Run tests to verify they pass**

## Chunk 4: Dashboard Automation

### Task 6: Implement batch sign-in, luck draw, and summary cards

**Files:**
- Create: `lib/features/dashboard/application/dashboard_controller.dart`
- Create: `lib/features/dashboard/domain/models/task_log_entry.dart`
- Create: `lib/features/dashboard/presentation/pages/dashboard_page.dart`
- Create: `lib/features/dashboard/presentation/widgets/summary_panel.dart`
- Create: `lib/features/dashboard/presentation/widgets/log_panel.dart`
- Test: `test/features/dashboard/application/dashboard_controller_test.dart`
- Test: `test/features/dashboard/presentation/dashboard_page_test.dart`

- [ ] **Step 1: Write failing tests for summary aggregation and batch execution**
- [ ] **Step 2: Run tests to verify they fail**
- [ ] **Step 3: Implement delayed concurrent execution and log append behavior**
- [ ] **Step 4: Run tests to verify they pass**

## Chunk 5: Device Station Placeholder

### Task 7: Implement device station UI and explicit unimplemented failure

**Files:**
- Create: `lib/features/devices/application/device_controller.dart`
- Create: `lib/features/devices/domain/models/device_station.dart`
- Create: `lib/features/devices/domain/models/region_option.dart`
- Create: `lib/features/devices/presentation/pages/device_station_page.dart`
- Create: `lib/features/devices/presentation/widgets/device_station_card.dart`
- Test: `test/features/devices/application/device_controller_test.dart`
- Test: `test/features/devices/presentation/device_station_page_test.dart`

- [ ] **Step 1: Write failing tests for region selection and unimplemented command dispatch**
- [ ] **Step 2: Run tests to verify they fail**
- [ ] **Step 3: Implement page, controller, placeholder data source, and explicit failure path**
- [ ] **Step 4: Run tests to verify they pass**

## Chunk 6: Final Integration

### Task 8: Wire navigation, theme, and app startup refresh

**Files:**
- Modify: `lib/app/app.dart`
- Modify: `lib/app/routes/app_pages.dart`
- Modify: `lib/app/bindings/app_binding.dart`
- Test: `test/app/navigation_test.dart`

- [ ] **Step 1: Write failing navigation test covering 4 pages**
- [ ] **Step 2: Run test to verify it fails**
- [ ] **Step 3: Implement bottom navigation or tab shell and startup initialization**
- [ ] **Step 4: Run test to verify it passes**

### Task 9: Run full verification

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Run formatter**

Run: `dart format lib test`
Expected: format completed

- [ ] **Step 2: Run static analysis**

Run: `flutter analyze`
Expected: no issues

- [ ] **Step 3: Run all tests**

Run: `flutter test`
Expected: all PASS

- [ ] **Step 4: Update README with startup and module notes**
