# Mobile Console Polish Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 压缩移动端首页与账号页布局，保留信息但减少占屏，并把按钮文案收束为更直接的操作表达。

**Architecture:** 保持现有页面结构不变，只重做首页统计卡组件、首页取水按钮样式，以及账号页顶部按钮区的布局组织。通过现有 widget test 覆盖移动端回归，避免再次出现窄屏溢出和文案回退。

**Tech Stack:** Flutter, GetX, flutter_test

---

## Chunk 1: 测试先行

### Task 1: 更新首页与账号页的预期测试

**Files:**
- Modify: `test/app/console_shell_responsive_test.dart`
- Modify: `test/app/console_shell_test.dart`
- Modify: `test/features/dashboard/presentation/dashboard_page_test.dart`

- [ ] **Step 1: 写失败测试**
- [ ] **Step 2: 运行对应测试并确认因当前界面不满足新预期而失败**
- [ ] **Step 3: 记录失败点：统计卡布局、按钮文案、自动化标题**

## Chunk 2: 首页收口

### Task 2: 重做移动端统计卡

**Files:**
- Modify: `lib/features/dashboard/presentation/pages/dashboard_page.dart`
- Modify: `lib/features/dashboard/presentation/widgets/summary_panel.dart`

- [ ] **Step 1: 写出“窄屏统计卡仍同排”的最小约束**
- [ ] **Step 2: 实现紧凑双列统计卡**
- [ ] **Step 3: 运行首页相关测试确认通过**

### Task 3: 收紧取水按钮与字段噪音

**Files:**
- Modify: `lib/features/dashboard/presentation/widgets/dispatch_workbench_section.dart`

- [ ] **Step 1: 写出“按钮只保留图标 + 容量”的失败测试**
- [ ] **Step 2: 实现按钮与字段文案调整**
- [ ] **Step 3: 运行首页相关测试确认通过**

## Chunk 3: 账号页收口

### Task 4: 移除自动化标题块并整合按钮区

**Files:**
- Modify: `lib/features/credentials/presentation/pages/credential_page.dart`
- Modify: `lib/features/credentials/presentation/widgets/credential_automation_section.dart`

- [ ] **Step 1: 写出“账号页不显示自动化标题，只显示两个动作按钮”的失败测试**
- [ ] **Step 2: 实现统一按钮带布局**
- [ ] **Step 3: 运行账号页测试确认通过**

## Chunk 4: 全量验证

### Task 5: 格式化并验证

**Files:**
- Modify: `lib/...`
- Modify: `test/...`

- [ ] **Step 1: 运行 `dart format` 格式化本轮变更文件**
- [ ] **Step 2: 运行相关 `flutter test`**
- [ ] **Step 3: 运行 `flutter analyze`**

Plan complete and saved to `docs/superpowers/plans/2026-04-16-mobile-console-polish.md`. 用户已确认，直接执行。
