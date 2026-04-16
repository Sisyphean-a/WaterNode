# Home Console Simplify Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 移除首页无意义的设备列表层级，简化状态区，并把取水按钮改成等宽大按钮加二次确认。

**Architecture:** 设备控制器改为内部聚合所有设备列表，UI 只保留账户和设备终端两个选择。首页移除冗余状态文案，按钮改为双列等宽布局，并在点击后弹出确认对话框再执行取水。

**Tech Stack:** Flutter, GetX, flutter_test

---

## Chunk 1: 测试先行

### Task 1: 更新首页 widget tests

**Files:**
- Modify: `test/features/dashboard/presentation/dashboard_page_test.dart`
- Modify: `test/app/console_shell_responsive_test.dart`

- [ ] **Step 1: 写失败测试**
- [ ] **Step 2: 运行测试确认因仍存在设备列表、状态文案、旧按钮交互而失败**

### Task 2: 更新控制器 tests

**Files:**
- Modify: `test/features/devices/application/device_controller_test.dart`

- [ ] **Step 1: 写失败测试，覆盖“默认当前村设备 + 设备终端含所有设备”**
- [ ] **Step 2: 运行测试确认失败**

## Chunk 2: 控制器与页面实现

### Task 3: 简化设备控制器

**Files:**
- Modify: `lib/features/devices/application/device_controller.dart`

- [ ] **Step 1: 聚合所有设备到单一 stations 列表**
- [ ] **Step 2: 默认选中当前村设备，否则选第一个在线设备**
- [ ] **Step 3: 移除页面对设备列表下拉的依赖**

### Task 4: 重做首页交互

**Files:**
- Modify: `lib/features/dashboard/presentation/widgets/dispatch_workbench_section.dart`

- [ ] **Step 1: UI 只保留账户与设备终端**
- [ ] **Step 2: 移除状态文案区域**
- [ ] **Step 3: 双按钮等宽铺满一行并增加确认弹窗**

## Chunk 3: 验证

### Task 5: 格式化和验证

**Files:**
- Modify: `lib/...`
- Modify: `test/...`

- [ ] **Step 1: 运行 `dart format`**
- [ ] **Step 2: 运行相关 `flutter test`**
- [ ] **Step 3: 运行 `flutter analyze`**
