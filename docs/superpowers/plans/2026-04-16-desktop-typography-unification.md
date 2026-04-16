# Desktop Typography Unification Implementation Plan (已废弃)

> **状态：** 该计划原本用于验证“统一主题 + 仓库自带中文字体”路线，现已被
> 包体优化主线替代，不再执行。

**Goal:** 记录这条计划为何终止，并指向当前生效的系统字体栈方案。

**Architecture:** 当前实现继续在 `lib/app/theme/` 中集中定义 `ThemeData` 与
`TextTheme`，但字体来源改为系统字体回退栈，不再向仓库新增字体资产。

**Tech Stack:** Flutter, Dart, Material 3, flutter_test

---

## 废弃原因

- 仓库内置中文 OTF 会显著抬高 Android 与 Windows 发布包体积。
- 当前项目已把安装包瘦身作为更高优先级工作项，并删除历史遗留的大字体资源。
- 统一排版目标仍然保留，但实现方式收敛为系统字体回退栈 + 主题层字重控制。

## 当前替代方案

- `lib/app/theme/app_theme.dart`
  - Android 使用 `sans-serif` 作为主字体族。
  - Windows 使用 `Microsoft YaHei UI` 作为主字体族。
  - 其余候选字体仅作为系统可用字体名回退，不对应仓库内置资源。
- `test/app/theme/app_theme_test.dart`
  - 锁定当前主题回退栈与字重分层。
- `docs/release-packaging.md`
  - 记录 48M 中文 OTF 已移除。
  - 要求发布前执行 `flutter test test/packaging`。

## 执行结论

- 不再新增中文字体文件。
- 不再修改 `pubspec.yaml` 注册字体资产。
- 若后续再次评估桌面排版问题，应先对包体影响做量化，再决定是否重新立项。
