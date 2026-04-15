# WaterNode

WaterNode 是一个基于 Flutter 的内部测试控制台，当前仅面向
Android 和 Windows。应用采用统一控制台壳层：首页只保留信息展示、
运行快照和取水入口；批量任务、终端管理、凭证管理与登录授权统一
通过可折叠左侧边栏进入。

## 当前界面结构

- `首页概览`：账号统计、取水入口、最近运行快照
- `任务中心 / 批量任务`：执行批量打卡、批量积分抽取，查看执行日志
- `设备中心 / 终端大厅`：区域筛选、终端列表、取水指令下发
- `账号中心 / 凭证管理`：查看测试账号状态、刷新账号有效性
- `账号中心 / 登录授权`：发送验证码并新增登录凭证

## 技术与仓库约束

- `GetX + Dio + Hive` 分层实现页面、控制器、网络与存储
- 动态 Header 工厂按 Token payload 生成
  `CUSTOMER_APP` / `APPLETS` 请求头
- 统一通过 `ConsoleShellPage` 承接主界面路由，保持首页与功能页风格一致
- 仓库仅保留 `android/` 与 `windows/` 平台模板，`ios/`、`linux/`、
  `macos/`、`web/` 和 `.metadata` 已移除并加入忽略规则

## 运行

```bash
flutter pub get
flutter run -d windows
```

Android 调试可用：

```bash
flutter run -d android
```

## 验证

```bash
dart format lib test
flutter analyze
flutter test
```
