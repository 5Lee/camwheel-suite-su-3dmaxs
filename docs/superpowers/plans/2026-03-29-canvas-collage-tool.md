# Canvas Collage Tool Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a new CamWheel toolbar/menu tool that opens an embedded infinite-canvas collage web app, while sharing the same frontend core with a standalone local HTML entry point.

**Architecture:** Keep plugin orchestration in Ruby: `main.rb` registers the command, a dedicated HtmlDialog wrapper opens the app, and a small UI bridge handles file-open/file-save interactions for the embedded mode. Keep collage behavior in a focused frontend module under a new `web_canvas_tool/` directory so both `HtmlDialog` and `standalone.html` reuse one JS/CSS implementation.

**Tech Stack:** SketchUp Ruby API, HtmlDialog, plain HTML/CSS/JavaScript, Minitest

---

## Chunk 1: Ruby Entry Points

### Task 1: Add failing tests for the new command and dialog wrapper

**Files:**
- Modify: `test/cam_wheel/main_boot_test.rb`
- Modify: `test/cam_wheel/main_tool_reference_test.rb`
- Create: `test/cam_wheel/canvas_tool_dialog_test.rb`

- [ ] **Step 1: Write the failing tests**
  - Add a boot test asserting the new collage command is added to toolbar/menu.
  - Add a tool-reference test asserting the new command exists on `CamWheel`.
  - Add a dialog test asserting `show` opens an `HtmlDialog` pointing at the new collage entry HTML.
- [ ] **Step 2: Run tests to verify they fail**
  - Run: `ruby -Itest test/cam_wheel/main_boot_test.rb && ruby -Itest test/cam_wheel/main_tool_reference_test.rb && ruby -Itest test/cam_wheel/canvas_tool_dialog_test.rb`
- [ ] **Step 3: Write minimal implementation**
  - Add a new command and icon hook in `cam_wheel/main.rb`.
  - Create a dedicated dialog wrapper in `cam_wheel/ui/canvas_tool_dialog.rb`.
  - Load the new dialog file from `main.rb`.
- [ ] **Step 4: Run tests to verify they pass**
  - Run: `ruby -Itest test/cam_wheel/main_boot_test.rb && ruby -Itest test/cam_wheel/main_tool_reference_test.rb && ruby -Itest test/cam_wheel/canvas_tool_dialog_test.rb`

### Task 2: Add the icon asset and bridge skeleton

**Files:**
- Create: `cam_wheel/assets/icons/canvas_tool.svg`
- Create: `cam_wheel/ui/canvas_tool_bridge.rb`
- Modify: `cam_wheel/ui/canvas_tool_dialog.rb`
- Modify: `test/cam_wheel/canvas_tool_dialog_test.rb`
- Create: `test/cam_wheel/canvas_tool_bridge_test.rb`

- [ ] **Step 1: Write the failing tests**
  - Add a bridge test asserting file-open/file-save callbacks can be bound to the dialog.
  - Extend the dialog test to assert the bridge is attached.
- [ ] **Step 2: Run tests to verify they fail**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_dialog_test.rb && ruby -Itest test/cam_wheel/canvas_tool_bridge_test.rb`
- [ ] **Step 3: Write minimal implementation**
  - Implement a bridge with callback stubs for open/save interactions.
  - Wire the bridge into the dialog and register the new icon in `main.rb`.
- [ ] **Step 4: Run tests to verify they pass**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_dialog_test.rb && ruby -Itest test/cam_wheel/canvas_tool_bridge_test.rb`

## Chunk 2: Shared Frontend Shell

### Task 3: Create the shared web-canvas frontend structure

**Files:**
- Create: `cam_wheel/web_canvas_tool/index.html`
- Create: `cam_wheel/web_canvas_tool/standalone.html`
- Create: `cam_wheel/web_canvas_tool/canvas_tool.js`
- Create: `cam_wheel/web_canvas_tool/canvas_tool.css`
- Create: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`

- [ ] **Step 1: Write the failing test**
  - Add a structure test asserting both HTML entry files and shared JS/CSS files exist.
  - Assert both HTML files reference the same shared JS/CSS assets.
- [ ] **Step 2: Run test to verify it fails**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
- [ ] **Step 3: Write minimal implementation**
  - Create both HTML entry points with a shared three-column shell.
  - Add the shared stylesheet and script references.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

### Task 4: Implement the base infinite-canvas shell

**Files:**
- Modify: `cam_wheel/web_canvas_tool/index.html`
- Modify: `cam_wheel/web_canvas_tool/standalone.html`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.css`

- [ ] **Step 1: Write the failing test**
  - Add assertions in the frontend structure test for visible app regions: toolbar, asset list, canvas viewport, properties panel, and export control placeholders.
- [ ] **Step 2: Run test to verify it fails**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
- [ ] **Step 3: Write minimal implementation**
  - Add the shell markup and minimal JS state bootstrapping for viewport pan/zoom and empty selection state.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

## Chunk 3: Core Editing Features

### Task 5: Implement image import, placement, selection, and transform controls

**Files:**
- Modify: `cam_wheel/ui/canvas_tool_bridge.rb`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.css`
- Modify: `cam_wheel/web_canvas_tool/index.html`
- Modify: `cam_wheel/web_canvas_tool/standalone.html`
- Create: `test/cam_wheel/canvas_tool_bridge_test.rb`

- [ ] **Step 1: Write the failing test**
  - Extend bridge tests to assert embedded mode can request file picks and save payloads.
  - Add structure-level assertions that upload, layer actions, and properties fields exist in both HTML entry points.
- [ ] **Step 2: Run tests to verify they fail**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_bridge_test.rb && ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
- [ ] **Step 3: Write minimal implementation**
  - Add frontend image import flow for both embedded and standalone modes.
  - Implement single-item selection, drag move, scale, rotate, z-order actions, and delete.
- [ ] **Step 4: Run tests to verify they pass**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_bridge_test.rb && ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

### Task 6: Implement rectangular crop mode and export flow

**Files:**
- Modify: `cam_wheel/ui/canvas_tool_bridge.rb`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.css`
- Modify: `cam_wheel/web_canvas_tool/index.html`
- Modify: `cam_wheel/web_canvas_tool/standalone.html`
- Modify: `test/cam_wheel/canvas_tool_bridge_test.rb`
- Modify: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`

- [ ] **Step 1: Write the failing test**
  - Add structure assertions for crop-mode controls and export format controls.
  - Extend bridge tests to assert embedded export triggers a save callback with file data.
- [ ] **Step 2: Run tests to verify they fail**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_bridge_test.rb && ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
- [ ] **Step 3: Write minimal implementation**
  - Add non-destructive rectangular crop state to frontend items.
  - Implement export of the composed canvas, using browser download in standalone mode and bridge save in embedded mode.
- [ ] **Step 4: Run tests to verify they pass**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_bridge_test.rb && ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

### Task 7: Add square-corner rendering and drag snapping

**Files:**
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.css`
- Modify: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`

- [ ] **Step 1: Write the failing test**
  - Add structure assertions that `.canvas-item` no longer uses rounded corners.
  - Add script assertions for drag snapping constants/hooks so the interaction contract is pinned.
- [ ] **Step 2: Run tests to verify they fail**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
- [ ] **Step 3: Write minimal implementation**
  - Remove rounded corners from the canvas item shell and crop box.
  - Add drag snapping that prefers alignment with nearby image edges/centers and falls back to grid snapping.
- [ ] **Step 4: Run tests to verify they pass**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

### Task 8: Refine navigation, snapping guides, and initial placement

**Files:**
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.css`
- Modify: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`

- [ ] **Step 1: Write the failing test**
  - Add structure assertions for visible snap-guide hooks and the middle-mouse pan / initial placement constants in the shared script.
- [ ] **Step 2: Run tests to verify they fail**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
- [ ] **Step 3: Write minimal implementation**
  - Reserve middle mouse for viewport panning even when pressing on an image.
  - Render horizontal/vertical snap guides while dragging and clear them on drag end.
  - Reduce imported image default size and spacing so the initial viewport keeps more working room.
- [ ] **Step 4: Run tests to verify they pass**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

### Task 9: Add marquee multi-selection and selection-based export

**Files:**
- Modify: `cam_wheel/web_canvas_tool/index.html`
- Modify: `cam_wheel/web_canvas_tool/standalone.html`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.css`
- Modify: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`

- [ ] **Step 1: Write the failing test**
  - Add structure assertions for export scale controls, marquee-selection hooks, and multi-selection state fields in the shared frontend.
- [ ] **Step 2: Run tests to verify they fail**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
- [ ] **Step 3: Write minimal implementation**
  - Replace single-selection state with active-selection plus selected-id collection.
  - Add left-button marquee selection from empty space and grouped dragging for selected items.
  - Export only the selected items by their outer bounds, with `1x / 2x / 原图优先` scale options.
- [ ] **Step 4: Run tests to verify they pass**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

## Chunk 4: Verification and Documentation

### Task 10: Update manual test coverage

**Files:**
- Modify: `docs/manual-test-checklist.md`

- [ ] **Step 1: Update the checklist**
  - Add a section covering the new collage tool entry, standalone HTML launch, image placement, crop, and export verification.
- [ ] **Step 2: Review wording for consistency**
  - Keep bullets short and aligned with the existing checklist style.

### Task 11: Run syntax and regression verification

**Files:**
- Modify: `cam_wheel/main.rb`
- Modify: `cam_wheel/ui/canvas_tool_dialog.rb`
- Modify: `cam_wheel/ui/canvas_tool_bridge.rb`
- Modify: `cam_wheel/web_canvas_tool/index.html`
- Modify: `cam_wheel/web_canvas_tool/standalone.html`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.css`
- Modify: `docs/manual-test-checklist.md`
- Test: `test/cam_wheel/main_boot_test.rb`
- Test: `test/cam_wheel/main_tool_reference_test.rb`
- Test: `test/cam_wheel/canvas_tool_dialog_test.rb`
- Test: `test/cam_wheel/canvas_tool_bridge_test.rb`
- Test: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`

- [ ] **Step 1: Run Ruby syntax checks**
  - Run: `ruby -c cam_wheel/main.rb && ruby -c cam_wheel/ui/canvas_tool_dialog.rb && ruby -c cam_wheel/ui/canvas_tool_bridge.rb`
- [ ] **Step 2: Run focused regression tests**
  - Run: `ruby -Itest test/cam_wheel/main_boot_test.rb && ruby -Itest test/cam_wheel/main_tool_reference_test.rb && ruby -Itest test/cam_wheel/canvas_tool_dialog_test.rb && ruby -Itest test/cam_wheel/canvas_tool_bridge_test.rb && ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
- [ ] **Step 3: Run the full suite**
  - Run: `for test_file in test/cam_wheel/*_test.rb; do ruby -Itest "$test_file" || exit 1; done`
