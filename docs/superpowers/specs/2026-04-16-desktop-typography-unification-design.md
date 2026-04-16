# WaterNode 桌面端字体统一设计（已废弃）

> 2026-04-16 这份设计没有按原方案落地。后续为了继续压缩 Android 与 Windows
> 安装包体积，项目放弃了“向仓库新增中文 OTF 资产”的做法，当前真实状态以
> `docs/ARCHITECTURE.md`、`docs/release-packaging.md` 和
> `lib/app/theme/app_theme.dart` 为准。

## 原始背景

- 当时要处理 Windows 中文文本粗细不一致的问题。
- 初版思路倾向于通过统一主题来收敛 `TextTheme` 和局部字重覆盖。
- 探索阶段曾考虑把中文字体文件直接放进仓库，以减少系统字体差异。

## 废弃原因

- 中文 OTF 资产会明显推高 Android APK 和 Windows 安装器体积。
- 当前主线优先目标是控制发布包大小，而不是追求字体文件的完全一致性。
- 现有主题层已经可以通过系统字体回退栈和统一字重配置，满足当前界面的可读性要求。

## 当前结论

- 不再向仓库提交桌面端中文字体资产。
- 应用继续使用系统字体回退栈：
  - Android 优先 `sans-serif`
  - Windows 优先 `Microsoft YaHei UI`
- 排版统一工作保留在主题层完成，不再依赖仓库内置字体文件。

## 相关落点

- `lib/app/theme/app_theme.dart`：当前主题与系统字体回退配置
- `test/app/theme/app_theme_test.dart`：主题回退栈守护测试
- `docs/release-packaging.md`：发布包瘦身约束与验证命令
