# Canvas Export Modes Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove export scale options from the canvas tool and support both merged export and per-item export using original-size output.

**Architecture:** Keep the existing export pipeline centered in `canvas_tool.js`, but simplify it so every export path uses original-size layout generation. Expose two toolbar actions for merged and per-item export while leaving the context-menu export action mapped to merged export for consistency.

**Tech Stack:** Plain HTML/CSS/JavaScript, Minitest

---

## Chunk 1: Export UI Contract

### Task 1: Update structure tests for the new export controls

**Files:**
- Modify: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`
- Modify: `cam_wheel/web_canvas_tool/index.html`
- Modify: `cam_wheel/web_canvas_tool/standalone.html`

- [ ] **Step 1: Write the failing test**
  - Assert both HTML entry files no longer include `data-field="export-scale"`.
  - Assert both HTML entry files include `data-action="export-merged"` and `data-action="export-individual"`.
- [ ] **Step 2: Run test to verify it fails**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
- [ ] **Step 3: Write minimal implementation**
  - Remove the export-scale select from both HTML files.
  - Add separate merged-export and per-item-export buttons.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

## Chunk 2: Export Logic

### Task 2: Replace scale-based export with original-size merged/per-item export

**Files:**
- Modify: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`

- [ ] **Step 1: Write the failing test**
  - Assert the script defines `exportSelectedAsMergedImage`, `exportSelectedAsSeparateImages`, and `buildSingleItemExportLayout`.
  - Assert the script no longer references `exportScale` or `resolveExportScaleFactor`.
- [ ] **Step 2: Run test to verify it fails**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
- [ ] **Step 3: Write minimal implementation**
  - Remove scale state and listeners.
  - Route merged export through original-size layout only.
  - Add per-item export loop with unique file naming.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

## Chunk 3: Verification

### Task 3: Run syntax and regression checks

**Files:**
- Modify: `cam_wheel/web_canvas_tool/index.html`
- Modify: `cam_wheel/web_canvas_tool/standalone.html`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`
- Modify: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`

- [ ] **Step 1: Run targeted checks**
  - Run: `node --check cam_wheel/web_canvas_tool/canvas_tool.js`
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
- [ ] **Step 2: Run regression suite**
  - Run: `for test_file in test/cam_wheel/*_test.rb; do ruby -Itest "$test_file" || exit 1; done`
