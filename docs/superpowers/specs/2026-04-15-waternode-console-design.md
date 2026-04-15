# WaterNode Console Design

**目标**

构建一个基于 Flutter 的 Android/Windows 双端内部测试控制台，支持多测试账号管理、批量签到抽奖、IoT 终端列表浏览，以及对未接入 IoT 接口的显式失败占位。

**范围**

- 首期交付 Flutter 工程骨架与 4 个页面路由。
- 实现短信验证码发送、验证码登录、账号状态检测、积分查询、签到、抽奖。
- 实现账号本地持久化、启动静默心跳检测、日志面板、积分汇总。
- 实现 IoT 页面结构、区域选择、设备列表占位数据源、指令按钮及显式报错。
- 预留 `getWaterStations` 与 `dispenseWater` 的 Service 接口签名，不做静默降级。

**架构设计**

应用采用 `GetX + Dio + Hive` 分层：

- `presentation` 负责页面、组件、交互绑定。
- `application` 负责控制器与任务编排。
- `domain` 负责实体、值对象、仓储接口。
- `infrastructure` 负责 Dio API、Hive 存储、JWT 载荷解析、Header 构造。

每个模块都通过接口与注入解耦。业务层不直接 new 网络客户端或存储实现，由启动入口统一装配依赖。

**模块拆分**

1. `auth`
   - 短信验证码发送。
   - 验证码登录。
   - Token 解析并生成账号凭证。
2. `credentials`
   - 多账号列表展示。
   - 本地持久化与加载。
   - 启动时并发检测账号有效性与积分。
3. `dashboard`
   - 汇总总账号数、在线数、失效数、总积分池。
   - 批量签到。
   - 批量抽奖。
   - 追加滚动日志。
4. `devices`
   - 区域级联选择。
   - 设备列表展示。
   - 指令按钮点击后抛出“接口未接入”错误。

**动态 Header 设计**

所有业务接口统一通过 `DynamicHeaderFactory` 生成 Header，不允许页面或 Service 写死业务 Header。

- 从 Token payload 中解析 `platformType`、`deviceId`、`userId`。
- `CUSTOMER_APP` 使用 Android 风格 `User-Agent` 与平台字段。
- `APPLETS` 使用小程序风格 `User-Agent` 与平台字段。
- 需要用户上下文的接口额外注入 `Token`、`User-Id`。

登录前接口使用固定 Android 预设 Header，仅用于发送验证码和短信登录。

**数据流**

1. 应用启动后初始化 Hive 与依赖注入。
2. 加载本地账号列表。
3. `CredentialController` 静默遍历账号并调用 `findUserInfo`。
4. 成功则更新在线状态、积分、最近检测时间；失效则标记无效。
5. `DashboardController` 基于账号仓储聚合统计并触发批处理任务。
6. `DeviceController` 读取区域与设备数据源，点击命令时调用占位 Service 并显式失败。

**错误处理**

- 网络失败、Token 解析失败、接口返回业务错误都向上抛出并记录到日志区。
- IoT TBD 接口调用直接抛出 `UnimplementedError`，UI 显示失败日志，不做禁用、不做伪成功。
- 账号失效不删除，只标记状态，便于复测。

**测试策略**

- 单元测试覆盖 Token 解析、动态 Header 生成、账号聚合统计、批处理节流逻辑。
- 控制器测试覆盖登录流程、账号心跳刷新、批量签到/抽奖结果聚合。
- Widget 测试覆盖 4 个页面基础渲染与关键按钮交互。
- 所有功能按 TDD 执行：先写失败测试，再写最小实现。

**目录规划**

- `lib/app/` 应用装配、路由、主题。
- `lib/core/` 常量、异常、工具、通用组件。
- `lib/features/auth/`
- `lib/features/credentials/`
- `lib/features/dashboard/`
- `lib/features/devices/`
- `test/` 与 `lib/` 结构镜像。

**非目标**

- 不接入真实 IoT 终端接口。
- 不做复杂权限体系、远程配置、埋点或离线任务队列。
