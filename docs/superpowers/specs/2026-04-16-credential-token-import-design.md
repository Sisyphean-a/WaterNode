# WaterNode Token 导入与复制设计

## 目标

在现有账号管理流程上补充两项能力：

- 在 `凭证管理` 页面手动粘贴 token 并导入账号。
- 在账号列表中直接复制已保存 token。

导入时不要求用户额外填写手机号，系统改为使用 token 解析结果和
`findUserInfo` 接口自动补齐账号信息。

## 范围

- `凭证管理` 顶部增加 `导入 Token` 按钮。
- 新增一个最小导入弹窗，包含多行 token 输入框和导入动作。
- 新增一条用户信息查询链路，使用 token 动态 Header 请求
  `GET /ids/app/user/findUserInfo`。
- 账号卡片增加 `复制 Token` 操作。

## 非目标

- 不改动短信验证码登录流程。
- 不改动账号主标识，仍使用手机号作为持久化键。
- 不做批量导入、二维码识别、文件导入。

## 架构设计

- `CredentialController` 负责凭证页交互编排，新增 token 导入状态和导入动作。
- 新增一个轻量 `AccountProfileGateway`，职责仅为通过 token 拉取用户手机号。
- `AccountProfileApi` 复用现有 `ApiClient` 与 `DynamicHeaderFactory`，不引入新网络层。
- 复制 token 通过 `Clipboard` 完成，保持为纯前端交互，不进入控制器状态。

## 数据流

1. 用户在凭证管理页点击 `导入 Token`。
2. 弹窗接收原始 token 字符串，控制器先执行 `trim`，空值直接报错。
3. 控制器调用 `TokenPayloadParser` 解析 `platformType`、`deviceId`、`userId`。
4. 控制器通过 `AccountProfileGateway` 请求 `findUserInfo`，强制读取响应中的手机号。
5. 控制器组装 `AccountCredential` 并保存到 `AccountRepository`。
6. 成功后刷新本地列表，失败则显式暴露错误信息。

## 错误处理

- token 为空：抛出 `FormatException('Token 不能为空')`。
- token 结构非法：沿用 `TokenPayloadParser` 解析异常。
- `findUserInfo` 返回非成功码：抛出显式异常。
- 用户信息缺少手机号：抛出 `FormatException`，不做字段兜底。

## 测试策略

- 控制器测试覆盖：
  - 导入 token 成功后保存凭证并刷新列表。
  - 空 token 导入失败并暴露错误。
- API 测试覆盖：
  - 用户信息接口成功解析手机号。
  - 非 `200` 响应显式失败。
- Widget 测试覆盖：
  - 凭证页显示 `导入 Token` 入口。
  - 账号卡片点击 `复制 Token` 后写入剪贴板。

## 风险

- `findUserInfo` 的手机号字段名如果与文档推断不一致，会在导入阶段显式失败。
- 当前仓库存储仍以手机号为键，同手机号多 token 会被覆盖；这是现有行为，
  本次不扩展多会话模型。
