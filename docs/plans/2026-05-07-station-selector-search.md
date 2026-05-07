# Station Selector Search Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a fuzzy local search box to the dashboard station selector bottom sheet.

**Architecture:** Keep search state local to the bottom sheet so the dashboard preserves its current behavior and the query resets naturally when the sheet closes. Reuse the existing in-memory station list from `DeviceController` and filter by `DeviceStation.name` only.

**Tech Stack:** Flutter, GetX, flutter_test

---

### Task 1: Lock selector search behavior with a failing widget test

**Files:**
- Modify: `test/features/dashboard/presentation/dashboard_page_test.dart`
- Modify: `lib/features/dashboard/presentation/widgets/dispatch_workbench_section.dart`

**Step 1: Write the failing test**
- Add a widget test that opens the station selector sheet, searches by a partial device name, verifies filtered results, verifies the empty state, closes the sheet, and verifies the query resets on reopen.

**Step 2: Run test to verify it fails**
- Run: `flutter test test/features/dashboard/presentation/dashboard_page_test.dart --plain-name "filters stations inside selector sheet and resets query when reopened"`
- Expected: FAIL because the search field does not exist yet.

**Step 3: Write minimal implementation**
- Add a local-state search field inside the station selector sheet.
- Filter the station list by `DeviceStation.name.contains(...)` using case-insensitive matching.
- Render the lightweight empty state when there are no matches.

**Step 4: Run test to verify it passes**
- Run: `flutter test test/features/dashboard/presentation/dashboard_page_test.dart --plain-name "filters stations inside selector sheet and resets query when reopened"`
- Expected: PASS.

### Task 2: Run targeted regression verification

**Files:**
- Modify: `lib/features/dashboard/presentation/widgets/dispatch_workbench_section.dart`
- Test: `test/features/dashboard/presentation/dashboard_page_test.dart`

**Step 1: Run dashboard widget tests**
- Run: `flutter test test/features/dashboard/presentation/dashboard_page_test.dart`
- Expected: PASS.

**Step 2: Run analyzer**
- Run: `flutter analyze`
- Expected: PASS.
