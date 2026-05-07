# Device Station Cache And Search Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make device list requests use `page-size: 100`, read station data from local cache by default, refresh from network only on manual action, and support local `deviceName` search.

**Architecture:** Keep `DeviceApi` focused on remote requests, add a small Hive-backed cache repository for station lists, and let `DeviceController` orchestrate cache-first loading plus local filtering. The page will send explicit refresh and search actions to the controller without adding network fallbacks.

**Tech Stack:** Flutter, GetX, Hive, flutter_test

---

### Task 1: Lock API paging behavior with tests

**Files:**
- Modify: `test/features/devices/infrastructure/device_api_test.dart`
- Modify: `lib/features/devices/infrastructure/device_api.dart`

**Step 1: Write the failing test**
- Change the existing paging-header expectation from `10` to `100`.

**Step 2: Run test to verify it fails**
- Run: `flutter test test/features/devices/infrastructure/device_api_test.dart`
- Expected: FAIL on the `page-size` expectation.

**Step 3: Write minimal implementation**
- Update the default station page size constant in `device_api.dart`.

**Step 4: Run test to verify it passes**
- Run: `flutter test test/features/devices/infrastructure/device_api_test.dart`
- Expected: PASS.

### Task 2: Add station cache persistence with tests

**Files:**
- Create: `lib/features/devices/domain/repositories/device_station_cache_repository.dart`
- Create: `lib/features/devices/infrastructure/hive_device_station_cache_repository.dart`
- Create: `test/features/devices/infrastructure/hive_device_station_cache_repository_test.dart`
- Modify: `lib/features/devices/domain/models/device_station.dart`

**Step 1: Write the failing test**
- Add a Hive persistence test that saves stations for one account key and reloads them.

**Step 2: Run test to verify it fails**
- Run: `flutter test test/features/devices/infrastructure/hive_device_station_cache_repository_test.dart`
- Expected: FAIL because the repository does not exist yet.

**Step 3: Write minimal implementation**
- Add serialization helpers on `DeviceStation`.
- Implement the cache repository with explicit account-scoped keys.

**Step 4: Run test to verify it passes**
- Run: `flutter test test/features/devices/infrastructure/hive_device_station_cache_repository_test.dart`
- Expected: PASS.

### Task 3: Add cache-first load and local search with tests

**Files:**
- Modify: `test/features/devices/application/device_controller_test.dart`
- Modify: `lib/features/devices/application/device_controller.dart`
- Create: `lib/features/devices/infrastructure/memory_device_station_cache_repository.dart`

**Step 1: Write the failing test**
- Add one test proving `prepareWorkbench()` uses cached stations without calling the remote list API.
- Add one test proving manual refresh fetches remote stations and overwrites cache.
- Add one test proving `deviceName` search filters only local cached data.

**Step 2: Run test to verify it fails**
- Run: `flutter test test/features/devices/application/device_controller_test.dart`
- Expected: FAIL because cache/search APIs are missing.

**Step 3: Write minimal implementation**
- Inject the cache repository into `DeviceController`.
- Separate cache-first load from explicit remote refresh.
- Keep an internal full list and expose filtered `stations`.

**Step 4: Run test to verify it passes**
- Run: `flutter test test/features/devices/application/device_controller_test.dart`
- Expected: PASS.

### Task 4: Wire the app and page UI

**Files:**
- Modify: `lib/app/dependencies/app_dependencies.dart`
- Modify: `lib/app/bindings/app_binding.dart`
- Modify: `lib/features/devices/presentation/pages/device_station_page.dart`

**Step 1: Write the failing test**
- Reuse existing controller tests for behavior and rely on analyzer/build for wiring safety.

**Step 2: Run verification to expose missing wiring**
- Run: `flutter analyze`
- Expected: FAIL until dependencies and page calls are wired.

**Step 3: Write minimal implementation**
- Open a Hive box for device station cache.
- Register the cache repository.
- Add a search field and bind refresh to the explicit remote-refresh method.

**Step 4: Run verification to verify it passes**
- Run: `flutter analyze`
- Expected: PASS.
