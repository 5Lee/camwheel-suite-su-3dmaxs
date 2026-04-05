# Canvas Image Slicing Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add image slicing to the shared CamWheel collage canvas so a single selected image can be split by grid or guides into multiple independent canvas items while keeping the source asset available for reuse.

**Architecture:** Keep slicing entirely in the shared frontend so both the SketchUp HtmlDialog entry and the standalone HTML entry reuse the same behavior. Extend the existing single-image editing state machine with a dedicated slice mode and draft state, then convert slice preview rectangles into normal canvas items that reuse the original `src` plus adjusted `crop` and display geometry.

**Tech Stack:** SketchUp Ruby API, HtmlDialog, plain HTML/CSS/JavaScript, Minitest

---

## Chunk 1: Structure and State Hooks

### Task 1: Add failing structure tests for slicing UI hooks

**Files:**
- Modify: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`
- Modify: `cam_wheel/web_canvas_tool/index.html`
- Modify: `cam_wheel/web_canvas_tool/standalone.html`

- [ ] **Step 1: Write the failing test**
  - Add assertions that both HTML entry files include:
    - `data-action="open-slice-mode"`
    - `data-role="slice-panel"`
    - `data-field="slice-rows"`
    - `data-field="slice-cols"`
    - `data-field="slice-vertical-guides"`
    - `data-field="slice-horizontal-guides"`
    - `data-action="clear-slice-vertical-guides"`
    - `data-action="clear-slice-horizontal-guides"`
    - `data-action="confirm-slice"`
    - `data-action="cancel-slice"`
    - `data-role="canvas-context-menu"`
- [ ] **Step 2: Run test to verify it fails**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
  - Expected: FAIL on missing slicing hooks.
- [ ] **Step 3: Write minimal implementation**
  - Add the slicing panel and context-menu container to both shared HTML entry points.
  - Keep the new panel hidden by default and aligned with the existing properties-panel structure.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

### Task 2: Add failing structure tests for slicing state and helper hooks

**Files:**
- Modify: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`

- [ ] **Step 1: Write the failing test**
  - Add script assertions for:
    - `sliceMode:`
    - `sliceDraft:`
    - `function enterSliceMode(`
    - `function exitSliceMode(`
    - `function buildGridSliceRects(`
    - `function buildGuideSliceRects(`
    - `function createSliceItems(`
- [ ] **Step 2: Run test to verify it fails**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
  - Expected: FAIL on missing slicing state or helper hooks.
- [ ] **Step 3: Write minimal implementation**
  - Add empty state fields and no-op helper shells in `canvas_tool.js`.
  - Expose only the minimal shared hooks needed by the structure test.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

## Chunk 2: Slice Mode UI and Right-Click Entry

### Task 3: Implement slice-mode panel visibility and single-selection gating

**Files:**
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.css`
- Modify: `cam_wheel/web_canvas_tool/index.html`
- Modify: `cam_wheel/web_canvas_tool/standalone.html`
- Modify: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`

- [ ] **Step 1: Write the failing test**
  - Add structure assertions for slice-mode hints and mode toggle fields:
    - `data-field="slice-mode"`
    - `data-role="slice-hint"`
  - Add script assertions for:
    - `function canSliceSelectedItem(`
    - `function updateSlicePanel(`
- [ ] **Step 2: Run test to verify it fails**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
  - Expected: FAIL on missing slice panel controls or helper hooks.
- [ ] **Step 3: Write minimal implementation**
  - Add a slice-mode selector (`grid` / `guides`) and hint region to both entry files.
  - Implement panel rendering so the slicing controls are only enabled for a single selected, zero-rotation item.
  - Ensure entering slice mode exits crop mode.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

### Task 4: Implement canvas right-click menu shell for image-specific actions

**Files:**
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.css`
- Modify: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`

- [ ] **Step 1: Write the failing test**
  - Add script assertions for:
    - `function openContextMenu(`
    - `function closeContextMenu(`
    - `event.button === 2`
    - `data-action="context-open-slice"`
- [ ] **Step 2: Run test to verify it fails**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
  - Expected: FAIL on missing right-click menu hooks.
- [ ] **Step 3: Write minimal implementation**
  - Add a lightweight custom context menu anchored to the pointer.
  - Show `图片切片` only when right-clicking a single image node.
  - Route the menu action into the same `enterSliceMode` path as the properties-panel button.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

## Chunk 3: Grid Slice Behavior

### Task 5: Build grid preview rectangles from the selected item crop

**Files:**
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`
- Modify: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`

- [ ] **Step 1: Write the failing test**
  - Add script assertions for:
    - `function normalizeSliceGrid(`
    - `function buildGridSliceRects(`
    - `function resolveSliceBaseRect(`
- [ ] **Step 2: Run test to verify it fails**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
  - Expected: FAIL on missing grid slice helpers.
- [ ] **Step 3: Write minimal implementation**
  - Normalize row/column values to valid integers.
  - Build crop-space rectangles using the selected item’s effective crop bounds.
  - Assign any remainder pixels to the last row and last column.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

### Task 6: Render grid preview overlay and wire grid inputs

**Files:**
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.css`
- Modify: `cam_wheel/web_canvas_tool/index.html`
- Modify: `cam_wheel/web_canvas_tool/standalone.html`

- [ ] **Step 1: Write the failing test**
  - Add structure assertions for:
    - `data-role="slice-preview-overlay"`
    - `data-role="slice-preview-count"`
  - Add script assertions for:
    - `function renderSlicePreview(`
    - `function updateSliceDraftFromGrid(`
- [ ] **Step 2: Run test to verify it fails**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
  - Expected: FAIL on missing preview overlay or update hooks.
- [ ] **Step 3: Write minimal implementation**
  - Draw the grid preview only on the active slice item.
  - Update preview rectangles live from row/column field changes.
  - Show the predicted slice count in the panel.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

## Chunk 4: Guide Slice Behavior

### Task 7: Build guide-based rectangles from typed positions

**Files:**
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`
- Modify: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`

- [ ] **Step 1: Write the failing test**
  - Add script assertions for:
    - `function parseGuideList(`
    - `function normalizeGuidePositions(`
    - `function buildGuideSliceRects(`
- [ ] **Step 2: Run test to verify it fails**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
  - Expected: FAIL on missing guide parsing helpers.
- [ ] **Step 3: Write minimal implementation**
  - Parse comma-separated guide inputs into numeric crop-space positions.
  - Clamp guides to the active crop bounds, sort them, and remove duplicates.
  - Build rectangular segments from horizontal and vertical partitions.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

### Task 8: Add draggable guide handles and input synchronization

**Files:**
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.css`
- Modify: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`

- [ ] **Step 1: Write the failing test**
  - Add script assertions for:
    - `function startGuideDrag(`
    - `function handleGuideDragMove(`
    - `function handleGuideDragEnd(`
    - `function syncGuideInputs(`
    - `function clearSliceGuides(`
- [ ] **Step 2: Run test to verify it fails**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
  - Expected: FAIL on missing drag or sync hooks.
- [ ] **Step 3: Write minimal implementation**
  - Render guide lines and handles in slice mode.
  - Allow dragging guide positions while preserving middle-mouse viewport pan.
  - Sync typed guide lists from drag changes and clear buttons.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

## Chunk 5: Slice Item Generation and Canvas Integration

### Task 9: Convert preview rectangles into normal canvas items

**Files:**
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`
- Modify: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`

- [ ] **Step 1: Write the failing test**
  - Add script assertions for:
    - `function createSliceItems(`
    - `function removeItemById(`
    - `function replaceItemWithSlices(`
- [ ] **Step 2: Run test to verify it fails**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
  - Expected: FAIL on missing slice replacement hooks.
- [ ] **Step 3: Write minimal implementation**
  - Create new items that reuse the source `src` and derive `crop`, `x`, `y`, `width`, and `height` from the slice rectangles.
  - Remove the original canvas item while leaving the asset card source data intact.
  - Keep the slices in the original visual footprint so they stitch back together seamlessly.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

### Task 10: Wire confirm/cancel flow and restore normal editing behavior

**Files:**
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.css`
- Modify: `cam_wheel/web_canvas_tool/index.html`
- Modify: `cam_wheel/web_canvas_tool/standalone.html`

- [ ] **Step 1: Write the failing test**
  - Add script assertions for:
    - `function confirmSlice(`
    - `function cancelSlice(`
    - `function selectedSliceSourceItem(`
- [ ] **Step 2: Run test to verify it fails**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
  - Expected: FAIL on missing confirm/cancel flow hooks.
- [ ] **Step 3: Write minimal implementation**
  - Confirm should replace the source item with slices and select the newly created items.
  - Cancel should discard the draft and restore normal item dragging.
  - Exit the custom context menu and hide the slice panel when leaving slice mode.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

## Chunk 6: Regression Coverage and Verification

### Task 11: Expand the manual test checklist for image slicing

**Files:**
- Modify: `docs/manual-test-checklist.md`

- [ ] **Step 1: Update the checklist**
  - Add manual steps for:
    - Entering slice mode from the properties panel
    - Entering slice mode from the right-click menu
    - Grid preview and confirmation
    - Guide typing, dragging, and confirmation
    - Source asset retention in the asset list
    - Slice export with `1x / 2x / 原图优先`
- [ ] **Step 2: Review wording for consistency**
  - Keep new checklist bullets short and aligned with the existing checklist style.

### Task 12: Run syntax and regression verification

**Files:**
- Modify: `cam_wheel/web_canvas_tool/index.html`
- Modify: `cam_wheel/web_canvas_tool/standalone.html`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.css`
- Modify: `docs/manual-test-checklist.md`
- Test: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`

- [ ] **Step 1: Run focused frontend structure coverage**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
  - Expected: PASS with the new slicing hooks covered.
- [ ] **Step 2: Run the full suite**
  - Run: `for test_file in test/cam_wheel/*_test.rb; do ruby -Itest "$test_file" || exit 1; done`
  - Expected: PASS with no regressions in the existing collage tool or plugin entry points.
- [ ] **Step 3: Run browser verification against the shared standalone page**
  - Run the standalone page at `http://127.0.0.1:8765/cam_wheel/web_canvas_tool/standalone.html`.
  - Verify:
    - Single selected image can enter slice mode from both entry points.
    - Grid slices stitch back into the original layout.
    - Guide slices stitch back into the original layout.
    - Middle mouse still pans while slice overlays are visible.
    - Export still respects selected slices and original-size output.
