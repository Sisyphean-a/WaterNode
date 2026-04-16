# Credential Token Import Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为凭证管理页增加手动 token 导入与 token 复制能力，并在导入时自动查询手机号。

**Architecture:** 保持现有 `GetX + Dio + Hive` 结构不变，在 `credentials` 域新增一条轻量账号信息查询网关，`CredentialController` 负责导入编排，页面负责弹窗与复制交互。导入链路先解析 token，再调用 `findUserInfo` 获取手机号，失败显式暴露。

**Tech Stack:** Flutter, Dart, GetX, Dio, Hive, flutter_test

---

## Chunk 1: 账号信息查询链路

### Task 1: 为用户信息接口建立回归测试

**Files:**
- Create: `test/features/credentials/infrastructure/account_profile_api_test.dart`
- Modify: `lib/features/credentials/domain/repositories/account_repository.dart`

- [ ] **Step 1: Write the failing test**
- [ ] **Step 2: Run `flutter test test/features/credentials/infrastructure/account_profile_api_test.dart` and verify it fails**
- [ ] **Step 3: Add `AccountProfileGateway` and `AccountProfileApi` with minimal parsing logic**
- [ ] **Step 4: Run the same test and verify it passes**

## Chunk 2: Token 导入控制器

### Task 2: 为导入行为建立失败测试

**Files:**
- Modify: `test/features/credentials/application/credential_controller_test.dart`
- Modify: `lib/features/credentials/application/credential_controller.dart`
- Modify: `lib/app/dependencies/app_dependencies.dart`

- [ ] **Step 1: Write failing tests for successful token import and empty token rejection**
- [ ] **Step 2: Run `flutter test test/features/credentials/application/credential_controller_test.dart` and verify it fails**
- [ ] **Step 3: Inject the parser and account profile gateway, then implement minimal import logic**
- [ ] **Step 4: Run the same test file and verify it passes**

## Chunk 3: 凭证页交互与复制功能

### Task 3: 为导入入口和复制行为建立界面测试

**Files:**
- Modify: `test/app/app_bootstrap_test.dart`
- Create: `test/features/credentials/presentation/credential_page_test.dart`
- Modify: `lib/features/credentials/presentation/pages/credential_page.dart`
- Modify: `lib/features/credentials/presentation/widgets/credential_card.dart`

- [ ] **Step 1: Write failing widget tests for the import button and clipboard copy**
- [ ] **Step 2: Run the affected widget tests and verify they fail**
- [ ] **Step 3: Implement the import dialog and copy token button with minimal UI**
- [ ] **Step 4: Run the same widget tests and verify they pass**

## Chunk 4: 回归验证

### Task 4: 验证导入链路与现有行为

**Files:**
- Modify: `lib/app/dependencies/app_dependencies.dart`

- [ ] **Step 1: Run focused tests for credentials, auth, and app bootstrap**
- [ ] **Step 2: Run `flutter analyze`**
- [ ] **Step 3: Record any remaining gaps honestly if a command fails**
