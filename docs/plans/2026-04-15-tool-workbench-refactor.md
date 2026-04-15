# Tool Workbench Refactor Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 将 WaterNode 从展示型后台重构为单壳层常驻的紧凑工具工作台。

**Architecture:** 壳层改为单路由常驻，页面切换由 `ConsoleShellController` 管理，不再依赖整页路由替换。页面采用统一工具栏、状态条、数据列表与日志面板，减少卡片和说明文案，提升首屏信息密度。

**Tech Stack:** Flutter, Dart, GetX, flutter_test

---

### Task 1: 锁定新工作台交互

**Files:**
- Modify: `test/app/app_bootstrap_test.dart`
- Modify: `test/app/console_shell_test.dart`
- Modify: `test/app/console_shell_responsive_test.dart`
- Modify: `test/widget_test.dart`

**Step 1: Write the failing test**

- 断言首页出现工作台工具栏和快照区
- 断言点击侧栏后工作台导航仍常驻，主体切换到目标页
- 断言凭证页存在显式操作栏

**Step 2: Run test to verify it fails**

Run: `flutter test test/app test/widget_test.dart`
Expected: FAIL

**Step 3: Write minimal implementation**

- 更新壳层与页面到新结构

**Step 4: Run test to verify it passes**

Run: `flutter test test/app test/widget_test.dart`
Expected: PASS

### Task 2: 重构单壳层导航

**Files:**
- Modify: `lib/app/application/console_shell_controller.dart`
- Modify: `lib/app/presentation/pages/console_shell_page.dart`
- Create: `lib/app/presentation/widgets/console_navigation_catalog.dart`
- Create: `lib/app/presentation/widgets/console_sidebar.dart`
- Create: `lib/app/presentation/widgets/console_workspace_shell.dart`
- Modify: `lib/app/routes/app_pages.dart`
- Modify: `lib/app/routes/app_routes.dart`

**Step 1: Write the failing test**

- 让测试断言导航切换不依赖整页路由替换

**Step 2: Run test to verify it fails**

Run: `flutter test test/app/console_shell_test.dart -r compact`
Expected: FAIL

**Step 3: Write minimal implementation**

- 壳层常驻
- 页面切换改为控制器驱动

**Step 4: Run test to verify it passes**

Run: `flutter test test/app/console_shell_test.dart -r compact`
Expected: PASS

### Task 3: 重做页面与共用组件

**Files:**
- Modify: `lib/features/dashboard/presentation/pages/dashboard_page.dart`
- Modify: `lib/features/dashboard/presentation/pages/task_center_page.dart`
- Modify: `lib/features/dashboard/presentation/widgets/summary_panel.dart`
- Modify: `lib/features/dashboard/presentation/widgets/log_panel.dart`
- Modify: `lib/features/credentials/presentation/pages/credential_page.dart`
- Modify: `lib/features/credentials/presentation/widgets/credential_card.dart`
- Modify: `lib/features/devices/presentation/pages/device_station_page.dart`
- Modify: `lib/features/devices/presentation/widgets/device_station_card.dart`
- Modify: `lib/features/auth/presentation/pages/auth_page.dart`
- Modify: `lib/features/auth/presentation/widgets/auth_form.dart`

**Step 1: Write the failing test**

- 锁定关键工具栏、列表、状态条和操作区

**Step 2: Run test to verify it fails**

Run: `flutter test test/app test/widget_test.dart`
Expected: FAIL

**Step 3: Write minimal implementation**

- 用紧凑工作台布局重做所有页面

**Step 4: Run test to verify it passes**

Run: `flutter test test/app test/widget_test.dart`
Expected: PASS

### Task 4: 全量验证

**Files:**
- Modify: `README.md`

**Step 1: Run validation**

Run: `dart format lib test docs`
Expected: PASS

Run: `flutter analyze`
Expected: PASS

Run: `flutter test`
Expected: PASS
