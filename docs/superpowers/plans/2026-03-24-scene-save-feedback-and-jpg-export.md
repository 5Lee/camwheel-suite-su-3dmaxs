# Scene Save Feedback And JPG Export Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show a success notice only when a scene is actually created and switch the composition export pipeline from PNG to JPG.

**Architecture:** Keep the native SketchUp save-scene action in `CompositionOverlayTool`, but add a post-action scene-count check via a short timer so success messaging reflects the real result. Keep export orchestration in `ExportService`, changing only the file-format path and default filename extension while preserving the existing crop/resample behavior.

**Tech Stack:** SketchUp Ruby Tool API, SketchUp UI API, Minitest, CamWheel services/tools

---

## Chunk 1: Save Scene Feedback

### Task 1: Add failing tests for scene-save success detection

**Files:**
- Modify: `test/cam_wheel/composition_overlay_tool_test.rb`

- [ ] **Step 1: Write the failing test**
  - Add a test that triggers `save_view`, advances the queued timer, and asserts `UI.messagebox("视角已保存")` only after `pages.count` increases.
  - Add a second test that keeps `pages.count` unchanged and asserts no success dialog is shown.
- [ ] **Step 2: Run test to verify it fails**
  - Run: `ruby -Itest test/cam_wheel/composition_overlay_tool_test.rb`
- [ ] **Step 3: Write minimal implementation**
  - Update `cam_wheel/tools/composition_overlay_tool.rb` to capture the pre-action scene count, trigger the native action, and check scene count in a timer callback before showing the success dialog.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `ruby -Itest test/cam_wheel/composition_overlay_tool_test.rb`

## Chunk 2: JPG Export Path

### Task 2: Add failing tests for JPG defaults and temp export format

**Files:**
- Modify: `test/cam_wheel/export_service_test.rb`
- Modify: `test/cam_wheel/export_service_ui_resolution_test.rb`

- [ ] **Step 1: Write the failing test**
  - Update default filename expectations from `.png` to `.jpg`.
  - Add a UI-resolution test asserting the save panel default filename uses `.jpg`.
  - Add a UI-resolution test asserting the temp `write_image` filename uses `.jpg`.
- [ ] **Step 2: Run tests to verify they fail**
  - Run: `ruby -Itest test/cam_wheel/export_service_test.rb && ruby -Itest test/cam_wheel/export_service_ui_resolution_test.rb`
- [ ] **Step 3: Write minimal implementation**
  - Update `cam_wheel/services/export_service.rb` so default filenames and temporary export files use `.jpg`.
  - Keep the existing export dimensions, crop logic, and final image save behavior unchanged apart from the format.
- [ ] **Step 4: Run tests to verify they pass**
  - Run: `ruby -Itest test/cam_wheel/export_service_test.rb && ruby -Itest test/cam_wheel/export_service_ui_resolution_test.rb`

### Task 3: Refresh manual checklist

**Files:**
- Modify: `docs/manual-test-checklist.md`

- [ ] **Step 1: Update the checklist**
  - Add a check that successful scene creation shows `视角已保存`.
  - Update the export filename bullet from generic timestamp naming to `.jpg` naming.
- [ ] **Step 2: Review wording for consistency**
  - Keep the checklist wording short and aligned with existing bullets.

## Chunk 3: Verification

### Task 4: Run syntax and regression verification

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
