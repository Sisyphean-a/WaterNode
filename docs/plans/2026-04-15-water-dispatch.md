# Water Dispatch Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 接通 WaterNode 终端大厅的真实取水链路，让应用可以加载真实设备并发起接水。

**Architecture:** 保持 `GetX + Dio + Hive` 分层。设备域改为显式建模免费接水配置、设备列表与接水执行，`DeviceController` 负责把真实接口状态映射为页面可见状态，不保留假区域和假设备数据。

**Tech Stack:** Flutter, Dart, GetX, Dio, Hive, flutter_test

---

### Task 1: 建立设备域测试与模型

**Files:**
- Create: `docs/plans/2026-04-15-water-dispatch.md`
- Create: `lib/features/devices/domain/models/free_water_config.dart`
- Modify: `lib/features/devices/domain/models/device_station.dart`
- Modify: `lib/features/devices/domain/gateways/device_gateway.dart`
- Create: `test/features/devices/infrastructure/device_api_test.dart`
- Modify: `test/features/devices/application/device_controller_test.dart`

**Step 1: Write the failing tests**

- 为 `DeviceApi` 写设备列表、默认配置、接水业务错误测试。
- 为 `DeviceController` 写真实加载与接水日志测试。

**Step 2: Run tests to verify they fail**

Run: `flutter test test/features/devices`
Expected: FAIL，提示设备域接口/控制器能力缺失。

**Step 3: Write minimal implementation**

- 扩展设备模型字段。
- 为网关补齐 `getFreeWaterConfig`、带凭证的设备查询和接水方法。

**Step 4: Run tests to verify they pass**

Run: `flutter test test/features/devices`
Expected: PASS

### Task 2: 接入控制器与页面

**Files:**
- Modify: `lib/features/devices/application/device_controller.dart`
- Modify: `lib/features/devices/presentation/pages/device_station_page.dart`
- Modify: `lib/features/devices/presentation/widgets/device_station_card.dart`
- Modify: `lib/app/dependencies/app_dependencies.dart`
- Create: `lib/features/devices/infrastructure/memory_device_gateway.dart`

**Step 1: Write the failing tests**

- 更新/新增 Widget 测试，覆盖终端大厅真实入口文案与按钮。

**Step 2: Run tests to verify they fail**

Run: `flutter test test/app`
Expected: FAIL，提示页面仍依赖旧的假数据结构。

**Step 3: Write minimal implementation**

- 终端页改为“列表来源 + 免费配置 + 设备卡片 + 执行日志”。
- 内存依赖提供可用假网关，保证 Widget 测试不访问真实网络。

**Step 4: Run tests to verify they pass**

Run: `flutter test test/app`
Expected: PASS

### Task 3: 全量验证

**Files:**
- Modify: `README.md`

**Step 1: Run validation**

Run: `dart format lib test docs`
Expected: 所有文件格式化完成

Run: `flutter analyze`
Expected: PASS

Run: `flutter test`
Expected: PASS

Run: `flutter build windows --debug`
Expected: PASS
