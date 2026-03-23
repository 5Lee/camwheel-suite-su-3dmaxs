# VCB Mode Switch Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the composition overlay tool default to SketchUp-style FOV input while allowing right-click switching to focal-length input.

**Architecture:** Persist a lightweight `composition_vcb_input_mode` setting with a default of `fov`. Update the composition overlay tool so VCB label/value, user input parsing, and context-menu actions all route through the current mode instead of assuming focal length only.

**Tech Stack:** SketchUp Ruby Tool API, Minitest, CamWheel settings store

---

## Chunk 1: Tests First

### Task 1: Add failing VCB mode tests

**Files:**
- Modify: `test/cam_wheel/composition_overlay_tool_test.rb`
- Modify: `test/cam_wheel/settings_store_test.rb`

- [ ] **Step 1: Write failing tests** for default FOV mode, FOV VCB label/value, focal-mode switching, and right-click menu mode actions.
- [ ] **Step 2: Run targeted tests to verify they fail**
  - Run: `ruby -Itest test/cam_wheel/composition_overlay_tool_test.rb && ruby -Itest test/cam_wheel/settings_store_test.rb`
- [ ] **Step 3: Implement minimal production changes**
- [ ] **Step 4: Re-run targeted tests to verify they pass**

## Chunk 2: Verification

### Task 2: Regression verification

**Files:**
- Modify: `cam_wheel/tools/composition_overlay_tool.rb`
- Modify: `cam_wheel/data/settings_store.rb`
- Modify: `cam_wheel/constants.rb`

- [ ] **Step 1: Run syntax checks**
  - Run: `ruby -c cam_wheel/tools/composition_overlay_tool.rb && ruby -c cam_wheel/data/settings_store.rb && ruby -c cam_wheel/constants.rb`
- [ ] **Step 2: Run full suite**
  - Run: `for test_file in test/cam_wheel/*_test.rb; do ruby -Itest "$test_file" || exit 1; done`
