# WaterNode 工具化重构 TODO

关联设计文档：[2026-04-15-waternode-tool-rebuild-design.md](./2026-04-15-waternode-tool-rebuild-design.md)

## 1. 目标

按照设计文档完成 WaterNode 的破坏性工具化重构。重点不是保留旧页面，而是交付以下最终结果：

- 首页成为唯一主取水工作台
- 账号体系彻底统一为“账号管理”
- 日志独立成页
- 侧边栏交互自然
- 签到、余额、账单、取水四条关键链路都可确认、可追踪

## 2. 执行边界

### 必须遵守

- 以设计文档中的目标状态为准
- 不得把核心要求留在聊天里，所有关键约束都以文件为准
- 可以做破坏性重构
- 可以删除与目标结构冲突的旧页面职责
- 不得用弱化需求的方式“快速完成”

### 明确不要做

- 不要保留“数据源”命名
- 不要继续让首页显示日志和快捷操作
- 不要继续保留独立的主取水终端大厅
- 不要继续保留独立的主批量操作页
- 不要只支持 `15L`
- 不要把账号额度耗尽当成系统级失败

## 3. 涉及模块与文件范围

以下文件是本轮高概率需要调整的范围，执行时应优先围绕这些模块收敛，而不是在代码库中无目的扩散。

### 壳层与导航

- `lib/app/presentation/pages/console_shell_page.dart`
- `lib/app/presentation/widgets/console_navigation_catalog.dart`
- `lib/app/presentation/widgets/console_sidebar.dart`
- `lib/app/presentation/widgets/console_workspace_shell.dart`
- `lib/app/application/console_shell_controller.dart`

### 首页与日志

- `lib/features/dashboard/presentation/pages/dashboard_page.dart`
- `lib/features/dashboard/presentation/pages/task_center_page.dart`
- `lib/features/dashboard/presentation/widgets/summary_panel.dart`
- `lib/features/dashboard/presentation/widgets/log_panel.dart`
- `lib/features/dashboard/application/dashboard_controller.dart`
- `lib/features/dashboard/infrastructure/activity_api.dart`
- `lib/features/dashboard/domain/gateways/activity_gateway.dart`

### 账号管理

- `lib/features/credentials/presentation/pages/credential_page.dart`
- `lib/features/credentials/presentation/widgets/credential_card.dart`
- `lib/features/credentials/application/credential_controller.dart`
- `lib/features/credentials/domain/models/account_credential.dart`
- `lib/features/credentials/domain/repositories/account_repository.dart`
- `lib/features/credentials/infrastructure/hive_account_repository.dart`
- `lib/features/credentials/infrastructure/memory_account_repository.dart`

### 取水与设备域

- `lib/features/devices/presentation/pages/device_station_page.dart`
- `lib/features/devices/presentation/widgets/device_station_card.dart`
- `lib/features/devices/application/device_controller.dart`
- `lib/features/devices/infrastructure/device_api.dart`
- `lib/features/devices/infrastructure/memory_device_gateway.dart`
- `lib/features/devices/domain/gateways/device_gateway.dart`
- `lib/features/devices/domain/models/device_station.dart`
- `lib/features/devices/domain/models/free_water_config.dart`

### 绑定与依赖

- `lib/app/bindings/app_binding.dart`
- `lib/app/dependencies/app_dependencies.dart`
- `lib/app/routes/app_pages.dart`

### 相关测试

- `test/app/console_shell_test.dart`
- `test/app/console_shell_responsive_test.dart`
- `test/widget_test.dart`
- `test/features/dashboard/...`
- `test/features/credentials/...`
- `test/features/devices/...`

## 4. 任务分块

### Task A: 完成信息架构重排

- [ ] 首页重新定义为“取水工作台”
- [ ] 批量操作能力并入首页底部区域
- [ ] 日志从首页剥离成独立页面
- [ ] 终端大厅不再作为主取水入口
- [ ] 梳理导航，使首页、账号管理、日志页、登录授权页关系清晰

完成标志：

- 首页结构符合设计文档第 7 节
- 日志不再出现在首页
- 用户无需进入终端大厅即可取水

### Task B: 完成账号语义与账号管理重构

- [ ] 将“凭证管理”统一改为“账号管理”
- [ ] 将“数据源”统一改为“账号”
- [ ] 账号支持备注字段
- [ ] 备注可持久化
- [ ] 账号列表移除独立在线模块
- [ ] 账号可明确选择，用于取水流程

完成标志：

- UI 不再出现旧命名
- 账号备注可新增、编辑、持久化
- 用户能明确知道当前操作账号

### Task C: 首页核心取水区完成重构

- [ ] 首页中部拆成“账号选择 / 区域选择 / 取水按钮区”
- [ ] 默认账号使用积分最高账号
- [ ] 默认区域使用该账号对应默认区域
- [ ] 同时支持 `7.5L` 与 `15L`
- [ ] 清晰展示当前账号、当前区域、当前水量选择

完成标志：

- 首页直接可取水
- `7.5L` 与 `15L` 都可触达
- 默认选择逻辑符合设计文档

### Task D: 取水失败语义与多账号切换体验修正

- [ ] 把“超出每日取水次数”视为当前账号额度耗尽
- [ ] 失败时保留明确错误原因
- [ ] 如果存在其他账号，允许切换后继续操作
- [ ] 不把该错误伪装成系统异常或网络异常

完成标志：

- 额度耗尽能被识别为业务限制
- 用户可以通过切换账号继续完成目标

### Task E: 签到状态链路补齐

- [ ] 接入签到状态校验接口作为“是否已签到”的事实来源
- [ ] 页面可区分未签到、已签到、本次成功、失败
- [ ] 签到状态结果进入日志

完成标志：

- 不再出现“已经签到但界面完全不知道”的情况

### Task F: 余额与账单链路补齐

- [ ] 余额以 `coin/user` 返回的 `data.totalFee` 为准
- [ ] 首页总积分、账号积分、默认账号排序与该值一致
- [ ] 接入账单列表能力
- [ ] 能识别 `SIGN_IN` 与 `SCAN_FETCH_WATER`

完成标志：

- 用户可核对积分变化来源
- 余额展示与账单结果可相互印证

### Task G: 侧边栏交互修复

- [ ] 点击导航项后主体正常切换
- [ ] 在抽屉/折叠场景下自动收起侧边栏
- [ ] 保持壳层稳定，不产生整页刷新感

完成标志：

- 点击导航后的交互符合设计文档第 8.6 节

### Task H: 首页顶部统计区收缩

- [ ] 首页顶部只保留账号总数与总积分
- [ ] 两项并排展示
- [ ] 空间不足时收缩间距，不换行堆叠

完成标志：

- 首页顶部信息符合设计文档第 8.2 节

## 5. 接口约束清单

执行过程中，不要再向用户索要这些接口事实。以设计文档第 11 节为准，至少覆盖以下链路：

- [ ] `GET /pay/account/coin/user?accountType=COIN&userId=<userId>`
- [ ] `GET /marketing/userSgin/consSignDay`
- [ ] `GET /pay/user/accountDetail/bean/list`
- [ ] `GET /marketing/app/freeWaterActivityConfig/findOneConfig`
- [ ] `GET /marketing/app/waterDispenser/list/inVillage`
- [ ] `GET /marketing/app/waterDispenser/listPage?latitude&longitude`
- [ ] `GET /marketing/app/freeWaterActivity/fetchWaterByScan?deviceId=<deviceId>&num=<num>`

## 6. 清理任务

- [ ] 清理首页旧日志模块
- [ ] 清理首页旧快捷操作模块
- [ ] 清理旧“在线账号 / 失效账号”统计项
- [ ] 清理“数据源”相关遗留文案
- [ ] 清理与独立终端大厅、独立批量任务页强绑定的冗余入口或冗余文案
- [ ] 清理与新结构冲突的测试断言

## 7. 验证命令

执行完成后，至少运行以下验证：

```powershell
dart format lib test docs
flutter analyze
flutter test
```

如果页面结构、导航行为或关键接口测试有单独测试集，也应补充执行，并以全部通过为目标。

## 8. 预期结果

### 结果 1：产品结构正确

- 首页是主工作台
- 日志独立
- 账号管理命名统一

### 结果 2：核心动作可完成

- 可选账号
- 可选区域
- 可选 `7.5L` / `15L`
- 可批量执行

### 结果 3：状态可确认

- 知道账号积分是多少
- 知道今日是否已签到
- 知道积分变化来自哪里
- 知道取水失败是额度原因还是其他原因

### 结果 4：交互不别扭

- 侧边栏点击后会正确收起
- 页面切换不出现整页刷新感

