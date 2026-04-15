# 智能物联网设备测试管理控制台 (Flutter) 需求规格说明书

## 1. 项目背景与目标

本项目旨在开发一款基于 Flutter 的双端（Android / Windows）内部测试管理工具，用于模拟和管理多账号环境下的物联网设备（IoT）交互。 核心目标是实现多账号集中状态管理、自动化测试脚本执行（如批量签到打卡），以及针对远程 IoT 终端的指令下发测试。

## 2. 技术选型建议

- **前端框架：** Flutter (支持打包 Windows .exe 和 Android .apk)
- **状态管理：** GetX 或 Provider (推荐 GetX，方便路由跳转和全局状态注入)
- **网络请求：** Dio (便于配置全局拦截器、动态 Header 和统一错误处理)
- **本地存储：** Hive 或 shared_preferences (用于持久化存储多账号的 Token 和设备信息)
- **UI 组件库：** 默认 Material 3 设计规范，保持极简、极客风格。

## 3. 功能模块设计

### 3.1 多测试账号管理 (Account Dashboard)

- **账号接入：** 模拟手机号与验证码登录，获取测试 Token。

  **本地持久化：** 本地存储多个测试账号的凭证（Token、设备类型标识、设备 ID）。

  **状态心跳检测：** 启动应用时，静默遍历测试账号池，调用 `userInfo` 接口检测有效性，失效账号标记并在 UI 侧警示。

### 3.2 自动化测试引擎 (Task Automation)

- **批处理执行：** 支持一键遍历所有有效账号，并发执行“每日活跃度打卡（签到）”和“活跃度积分抽取（抽奖）”的模拟网络请求。
- **并发控制：** 引入延时错峰机制（防并发风暴），记录各账号的成功/失败状态。
- **资产汇总：** 统计所有测试账号当前的“活跃度积分”总额。

### 3.3 IoT 远程终端管理模块 (Remote Device Control)

- **终端目录大厅：** 支持级联选择（按区域划分），拉取对应区域的 IoT 终端设备列表。
- **指令下发测试：** 针对特定终端，系统自动匹配本地积分余额大于 0 的有效测试账号，将其 Token 注入 Header 后，向该终端发起“开启设备/下发资源”的网络调用。

## 4. 界面与交互设计 (UI 路由规划)

- **Page 1: 控制台首页 (Dashboard)**
  - 顶部：账号池状态（总账号数、在线/失效数、总积分池）。
  
    中部操作区：【执行批量打卡】、【执行批量积分抽取】按钮。
  
    下部日志区：滚动显示网络请求执行日志。
- **Page 2: 终端管理大厅 (Device Station)**
  
  - 顶部：区域级联选择器。
  
    列表：展示 IoT 终端卡片（设备名称、设备 ID、在线状态）。
  
    操作：每个卡片附带【下发指令】测试按钮。
- **Page 3: 凭证管理 (Credential List)**
  
  - 列表展示：手机号、当前积分余额、有效状态。
  
    悬浮按钮 (FAB)：新增测试账号。
- **Page 4: 登录授权页 (Auth Page)**
  
  - 表单：手机号、验证码输入框及获取按钮。

## 5. 核心技术痛点与避坑指南（AI 编程必看）

4. 本项目在网络层有严格的**动态 Header 适配需求**。 Service 层在构造 `Dio` 请求头时，必须解析 Token 的 Payload 载荷：

   1. 提取 `platformType` 字段。
   2. 若值为 `CUSTOMER_APP`，请求头中的 `User-Agent` 必须设为 `Dart/3.11`，并补充安卓环境特征字段。
   3. 若值为 `APPLETS`，请求头中的 `User-Agent` 必须设为 `Mozilla/5.0... WindowsWechat...`，并补充小程序特征字段。
   4. 任何业务接口调用，均不可写死静态 Header。
   
   *(具体 Header 字段见第 6 节)*

------

## 6. 现有 API 接口文档

### 6.1 发送短信验证码

- **Method:** POST

- **URL:** `https://gateway.exiaokang.cn/ids/pub/sms/sendCode`

- **Headers:** (采用 Android CUSTOMER_APP 预设)

  - `platform-type`: `CUSTOMER_APP`
  - `device-id`: `PQ3A.190605.08171456`
  - `application-id`: `cn.exiaokang.app.customer`

- **Body (JSON):**

  JSON

  ```
  {"mobile": "157xxxxxx", "businessType": "LOGIN"}
  ```

- **Response:** 解析返回的 `data.id` (此为 `smsCodeId`，登录接口必须使用)。

### 6.2 验证码登录/获取 Token

- **Method:** POST

- **URL:** `https://gateway.exiaokang.cn/ids/pub/login/loginRegisterBySmsCode`

- **Headers:** (同 6.1)

- **Body (JSON):**

  JSON

  ```
  {
    "mobile": "157xxxxxx",
    "smsCode": "123456",
    "smsCodeId": "上一步获取的id"
  }
  ```

- **Response:** 提取 `data.token` 进行持久化。

### 6.3 获取用户信息 (用于检测状态与查询余额)

- **Method:** GET
- **URL:** `https://gateway.exiaokang.cn/ids/app/user/findUserInfo`
- **Headers:** ⚠️ **必须根据 Token 动态生成**
  - 安卓型 (`platformType: CUSTOMER_APP`):
    - `User-Agent`: `Dart/3.11 (dart:io)`
    - `Platform-Type`: `CUSTOMER_APP`
    - `Device-Id`: Token内解析的值
    - `Token`: 你的Token
  - 小程序型 (`platformType: APPLETS`):
    - `User-Agent`: `Mozilla/5.0... WindowsWechat...`
    - `Platform-Type`: `APPLETS`
    - `Device-Id`: Token内解析的值
    - `Token`: 你的Token
- **Response:** 状态码 `200` 且 `code=="200"` 为在线，`h009` 为失效。

### 6.4 签到与抽奖接口

- **签到接口:** GET `https://gateway.exiaokang.cn/marketing/userSgin/signInClick`
- **抽奖接口:** GET `https://gateway.exiaokang.cn/marketing/app/turntable/luckDraw?townCode=`
- **Headers:** (遵循 6.3 动态 Header 规则，并附加 `User-Id: 解析出的userId`)

------

## 7. 待补充接口 (TBD)

*(这部分等待你后续抓包后补充，AI 开发时先预留 Service 层的方法签名)*

1. **获取取水点列表接口 (getWaterStations):**
   - 预计参数：地区编码 (Region Code)
   - 预计返回：取水点 ID、名称、设备状态。
2. **触发取水接口 (dispenseWater):**
   - 预计参数：取水点 ID (stationId)、出水量 (volume)
   - 预计逻辑：需要携带有效账号的 Token 发起请求扣减小康豆并下发出水指令。