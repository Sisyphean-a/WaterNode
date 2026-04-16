# Desktop Typography Unification Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为 WaterNode 接入项目内中文字体，并统一桌面端文本层级与字重，消除中文显示忽粗忽细的问题。

**Architecture:** 在 `lib/app/theme/` 中集中定义 `ThemeData` 与 `TextTheme`，将 `Noto Sans SC` 作为全局字体资源注册到应用，并收敛当前组件中分散的字重覆盖。组件尽量依赖统一主题，只保留少量必要强调。

**Tech Stack:** Flutter, Dart, Material 3, flutter_test

---

## Chunk 1: 主题回归测试

### Task 1: 为全局字体与字重目标建立失败测试

**Files:**
- Create: `test/app/theme/app_theme_test.dart`
- Modify: `lib/app/app.dart`

- [ ] **Step 1: Write the failing test**
- [ ] **Step 2: Run `flutter test test/app/theme/app_theme_test.dart` and verify it fails**
- [ ] **Step 3: Add the minimal app theme implementation**
- [ ] **Step 4: Run the same test and verify it passes**

## Chunk 2: 字体资源与主题接入

### Task 2: 接入项目字体并切换应用主题

**Files:**
- Create: `fonts/noto_sans_sc/NotoSansCJKsc-Regular.otf`
- Create: `fonts/noto_sans_sc/NotoSansCJKsc-Medium.otf`
- Create: `fonts/noto_sans_sc/NotoSansCJKsc-Bold.otf`
- Create: `lib/app/theme/app_theme.dart`
- Modify: `pubspec.yaml`
- Modify: `lib/app/app.dart`

- [ ] **Step 1: Download the font assets into the repo**
- [ ] **Step 2: Register the font family in `pubspec.yaml`**
- [ ] **Step 3: Wire `WaterNodeApp` to the new theme factory**
- [ ] **Step 4: Run `flutter test test/app/theme/app_theme_test.dart` and verify it stays green**

## Chunk 3: 文本样式收敛

### Task 3: 去掉分散的局部粗体

**Files:**
- Modify: `lib/app/presentation/widgets/console_sidebar.dart`
- Modify: `lib/app/presentation/widgets/console_workspace_shell.dart`
- Modify: `lib/app/presentation/widgets/workbench_section.dart`
- Modify: `lib/features/dashboard/presentation/widgets/summary_panel.dart`
- Modify: `lib/features/devices/presentation/widgets/device_station_card.dart`
- Modify: `lib/features/credentials/presentation/widgets/credential_card.dart`

- [ ] **Step 1: Remove redundant local `fontWeight` overrides**
- [ ] **Step 2: Keep only the minimal required emphasis**
- [ ] **Step 3: Run focused widget tests if any typography regressions appear**

## Chunk 4: 回归验证

### Task 4: 验证应用级排版方案

**Files:**
- Modify: `test/app/theme/app_theme_test.dart`

- [ ] **Step 1: Run `flutter test`**
- [ ] **Step 2: Run `flutter analyze`**
- [ ] **Step 3: Report the actual verification output honestly**
