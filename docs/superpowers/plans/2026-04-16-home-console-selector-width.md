# Home Console Selector Width Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让首页控制台在窄屏下使用纵向全宽选择器，扩大设备终端下拉菜单可见宽度。

**Architecture:** 保持现有首页控制台组件结构不变，只调整 `DispatchWorkbenchSection` 的响应式布局规则。通过测试先锁定窄屏宽度行为，再以最小改动修改布局计算逻辑，避免影响桌面端密度。

**Tech Stack:** Flutter, Dart, flutter_test

---

## Chunk 1: 测试先行

### Task 1: 锁定窄屏下选择器宽度行为

**Files:**
- Modify: `test/app/console_shell_responsive_test.dart`

- [ ] **Step 1: Write the failing test**

为窄屏首页增加断言，读取 `workbench-account-select` 和 `workbench-station-select` 的宽度，要求两者接近页面内容宽度，而不是旧的半宽。

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/app/console_shell_responsive_test.dart`
Expected: FAIL，提示选择器宽度仍为半宽布局。

- [ ] **Step 3: Write minimal implementation**

只修改首页控制台的窄屏布局逻辑，不改动业务状态。

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/app/console_shell_responsive_test.dart`
Expected: PASS

## Chunk 2: 响应式实现与回归

### Task 2: 调整首页控制台布局规则

**Files:**
- Modify: `lib/features/dashboard/presentation/widgets/dispatch_workbench_section.dart`

- [ ] **Step 1: 实现窄屏纵向全宽布局**

让窄屏下两个选择器按列排布并占满可用宽度；较宽屏幕继续沿用现有双列布局。

- [ ] **Step 2: 保持样式密度一致**

复用现有表单组件和间距，不新增装饰性容器或说明文案。

- [ ] **Step 3: 格式化文件**

Run: `dart format lib/features/dashboard/presentation/widgets/dispatch_workbench_section.dart test/app/console_shell_responsive_test.dart`

- [ ] **Step 4: 运行回归验证**

Run: `flutter test test/app/console_shell_responsive_test.dart test/app/console_shell_test.dart test/features/dashboard/presentation/dashboard_page_test.dart`
Expected: PASS

- [ ] **Step 5: 运行静态检查**

Run: `flutter analyze`
Expected: No issues found
