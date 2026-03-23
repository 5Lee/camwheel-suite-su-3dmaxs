# Composition Scene Save And Export Feedback Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a native SketchUp "save view" entry to the composition overlay context menu and improve export feedback with a success dialog plus timestamp-based default filenames.

**Architecture:** Keep the native-command bridge in the composition overlay tool because that tool owns the right-click menu. Centralize export default filename generation inside `ExportService` so UI code only reacts to success or cancellation and the file naming logic stays testable.

**Tech Stack:** SketchUp Ruby Tool API, SketchUp UI API, Minitest, CamWheel services/tools

---

## Chunk 1: Behavior Changes

### Task 1: Add failing tests for menu action, success dialog, and default filename generation

**Files:**
- Modify: `test/cam_wheel/composition_overlay_tool_test.rb`
- Modify: `test/cam_wheel/export_service_test.rb`
- Modify: `test/cam_wheel/export_service_ui_resolution_test.rb`

- [ ] **Step 1: Write the failing tests**
  - Add a menu test asserting `保存视图` exists in `CompositionOverlayTool#getMenu`.
  - Add a tool test asserting the save-view action calls a SketchUp native action bridge.
  - Add a tool test asserting successful export shows `UI.messagebox("图片已导出")`.
  - Add service tests for timestamped default filename generation with a saved model name and with an unsaved model fallback.
- [ ] **Step 2: Run targeted tests to verify they fail**
  - Run: `ruby -Itest test/cam_wheel/composition_overlay_tool_test.rb && ruby -Itest test/cam_wheel/export_service_test.rb && ruby -Itest test/cam_wheel/export_service_ui_resolution_test.rb`
- [ ] **Step 3: Implement the minimal production changes**
  - Update `cam_wheel/tools/composition_overlay_tool.rb` to add the new menu item, bridge the native save-view action, and show the export success dialog only when export succeeds.
  - Update `cam_wheel/services/export_service.rb` to derive the default filename from the current model name and a `%Y%m%d-%H%M%S` timestamp, with a `camwheel` fallback.
- [ ] **Step 4: Re-run targeted tests to verify they pass**
  - Run: `ruby -Itest test/cam_wheel/composition_overlay_tool_test.rb && ruby -Itest test/cam_wheel/export_service_test.rb && ruby -Itest test/cam_wheel/export_service_ui_resolution_test.rb`

### Task 2: Update manual verification coverage

**Files:**
- Modify: `docs/manual-test-checklist.md`

- [ ] **Step 1: Add checklist items**
  - Add a manual check for `构图辅助` right-click menu containing `保存视图`.
  - Add a manual check for successful export showing a dialog and using a `文件名-时间戳` default save name.
- [ ] **Step 2: Review wording for consistency**
  - Keep checklist language aligned with existing short imperative bullets.

## Chunk 2: Regression Verification

### Task 3: Run syntax and regression verification

**Files:**
- Modify: `cam_wheel/tools/composition_overlay_tool.rb`
- Modify: `cam_wheel/services/export_service.rb`
- Modify: `docs/manual-test-checklist.md`
- Test: `test/cam_wheel/composition_overlay_tool_test.rb`
- Test: `test/cam_wheel/export_service_test.rb`
- Test: `test/cam_wheel/export_service_ui_resolution_test.rb`

- [ ] **Step 1: Run syntax checks**
  - Run: `ruby -c cam_wheel/tools/composition_overlay_tool.rb && ruby -c cam_wheel/services/export_service.rb`
- [ ] **Step 2: Run focused regression tests**
  - Run: `ruby -Itest test/cam_wheel/composition_overlay_tool_test.rb && ruby -Itest test/cam_wheel/export_service_test.rb && ruby -Itest test/cam_wheel/export_service_ui_resolution_test.rb`
- [ ] **Step 3: Run the full suite**
  - Run: `for test_file in test/cam_wheel/*_test.rb; do ruby -Itest "$test_file" || exit 1; done`
