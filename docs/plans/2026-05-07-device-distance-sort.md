# Device Distance Sort Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Sort merged device stations by distance from the default in-village anchor coordinate.

**Architecture:** Keep the two-source fetch flow unchanged, but derive an anchor point from the first `in-village` station with valid coordinates. Use that anchor inside `DeviceController` sorting so cached and refreshed station lists share the same ordering logic.

**Tech Stack:** Flutter, GetX, flutter_test

---

### Task 1: Lock the distance-sort behavior with a failing test

**Files:**
- Modify: `test/features/devices/application/device_controller_test.dart`
- Modify: `lib/features/devices/application/device_controller.dart`

**Step 1: Write the failing test**
- Add a controller test that prepares a station list where `in-village` provides the anchor coordinate and other stations have different distances.

**Step 2: Run test to verify it fails**
- Run: `flutter test test/features/devices/application/device_controller_test.dart --plain-name "sorts merged stations by distance from first in-village coordinate"`
- Expected: FAIL because current ordering does not use coordinates.

**Step 3: Write minimal implementation**
- Derive the anchor coordinate from the first `in-village` station.
- Compare stations by computed distance first, then use stable fallbacks only when distance cannot be computed.

**Step 4: Run test to verify it passes**
- Run: `flutter test test/features/devices/application/device_controller_test.dart --plain-name "sorts merged stations by distance from first in-village coordinate"`
- Expected: PASS.

### Task 2: Run targeted regression verification

**Files:**
- Modify: `lib/features/devices/application/device_controller.dart`
- Test: `test/features/devices/application/device_controller_test.dart`

**Step 1: Run controller regression tests**
- Run: `flutter test test/features/devices/application/device_controller_test.dart`
- Expected: PASS.

**Step 2: Run analyzer**
- Run: `flutter analyze`
- Expected: PASS.
