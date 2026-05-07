# Station Selector Search Design

**Goal:** Add a fuzzy local search entry inside the station selector bottom sheet without changing the home dashboard layout or disrupting the existing visual language.

**Context:** The current dashboard workbench opens a bottom sheet for station selection. The device list is already available locally in memory, so the search can stay fully client-side and immediate. The user wants the search available in the selector itself and is explicitly concerned about preserving the current UI/UX quality.

## Interaction

- Keep the existing "目标水站终端" card as the only entry point.
- Open the same bottom sheet used today for station selection.
- Place a search input directly below the sheet title.
- Perform real-time fuzzy filtering against `deviceName`, which maps to `DeviceStation.name`.
- Show the full station list when the query is empty.
- Show a lightweight empty state text when nothing matches.
- Clear the search query when the sheet is closed so the next open starts clean.

## Visual Direction

- Reuse the current sheet language: rounded corners, soft surface tones, restrained contrast.
- Keep the search field embedded in the sheet rather than floating or visually dominant.
- Use a search icon on the left and the placeholder `搜索设备名`.
- Preserve the current station list tile design and spacing.
- Keep the list scroll behavior unchanged, with the search field fixed near the top for long lists.

## Scope

- Only add search UI and local filtering inside the station selector sheet.
- Do not change the home dashboard layout.
- Do not add network requests, cache changes, or backend dependencies.
- Do not change station selection behavior.

## Validation

- Widget test should verify:
  - the search field appears in the station selector sheet,
  - typing filters the visible stations,
  - an empty result shows `没有匹配的设备`,
  - closing and reopening the sheet resets the query and restores the full list.
