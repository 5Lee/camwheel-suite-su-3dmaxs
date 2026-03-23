# Cursor Restoration Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ensure CamWheel custom tools restore a normal cursor after orbit/pan/selection handoffs instead of leaving a stale native-tool cursor onscreen.

**Architecture:** Add explicit `onSetCursor` hooks to each active CamWheel tool so SketchUp always re-requests cursor state when the tool regains control. Keep the fix minimal by delegating to SketchUp's default cursor behavior instead of adding custom cursor assets.

**Tech Stack:** SketchUp Ruby Tool API, Minitest

---

## Chunk 1: Cursor Hooks

### Task 1: Add failing cursor tests

**Files:**
- Modify: `test/cam_wheel/align_view_tool_test.rb`
- Modify: `test/cam_wheel/penetration_tool_test.rb`
- Modify: `test/cam_wheel/composition_overlay_tool_test.rb`

- [ ] **Step 1: Write failing tests** asserting each tool implements `onSetCursor` and returns `false`.
- [ ] **Step 2: Run targeted tests to verify they fail**
  - Run: `ruby -Itest test/cam_wheel/align_view_tool_test.rb && ruby -Itest test/cam_wheel/penetration_tool_test.rb && ruby -Itest test/cam_wheel/composition_overlay_tool_test.rb`
- [ ] **Step 3: Implement minimal tool hooks** in each tool file.
- [ ] **Step 4: Re-run targeted tests to verify they pass**

### Task 2: Verify no regressions

**Files:**
- Modify: `cam_wheel/tools/align_view_tool.rb`
- Modify: `cam_wheel/tools/penetration_tool.rb`
- Modify: `cam_wheel/tools/composition_overlay_tool.rb`

- [ ] **Step 1: Run syntax checks**
  - Run: `ruby -c cam_wheel/tools/align_view_tool.rb && ruby -c cam_wheel/tools/penetration_tool.rb && ruby -c cam_wheel/tools/composition_overlay_tool.rb`
- [ ] **Step 2: Run full suite**
  - Run: `for test_file in test/cam_wheel/*_test.rb; do ruby -Itest "$test_file" || exit 1; done`
