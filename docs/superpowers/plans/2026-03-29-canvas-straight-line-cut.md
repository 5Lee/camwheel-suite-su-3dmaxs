# Canvas Straight-Line Cut Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a straight-line cut mode to the shared CamWheel collage canvas so a single unrotated image can be split into two polygon-backed pieces that stay in place, move independently, and export at original-quality density.

**Architecture:** Keep the feature entirely inside the shared frontend so both the SketchUp HtmlDialog entry and the standalone HTML entry get the same behavior. Extend the existing single-image edit state with a dedicated straight-line cut draft, generate two `polygon-image` items from one source image, and expand rendering plus export to support both rectangular and polygon-backed items without changing the Ruby bridge.

**Tech Stack:** SketchUp Ruby API, HtmlDialog, plain HTML/CSS/JavaScript, Minitest, manual browser verification

---

## File Map

- `cam_wheel/web_canvas_tool/index.html`
  Shared embedded entry markup; add straight-line cut toolbar button, mode action area, and context-menu hook.
- `cam_wheel/web_canvas_tool/standalone.html`
  Shared standalone entry markup; keep the same hooks as `index.html`.
- `cam_wheel/web_canvas_tool/canvas_tool.css`
  Style the straight-line cut overlay, handles, preview states, and polygon item shell without changing the existing collage look.
- `cam_wheel/web_canvas_tool/canvas_tool.js`
  Add straight-line cut state, geometry helpers, preview rendering, context-menu flow, polygon item rendering, and polygon-aware export.
- `test/cam_wheel/canvas_tool_frontend_structure_test.rb`
  Pin the new HTML hooks and JS function contracts so the shared frontend surface does not regress.
- `docs/manual-test-checklist.md`
  Extend the manual checklist with straight-line cut behavior and export validation.

## Chunk 1: UI Hooks and State Shell

### Task 1: Add failing structure tests for straight-line cut UI entry points

**Files:**
- Modify: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`
- Modify: `cam_wheel/web_canvas_tool/index.html`
- Modify: `cam_wheel/web_canvas_tool/standalone.html`

- [ ] **Step 1: Write the failing test**
  - Add assertions that both HTML entry files include:
    - `data-action="open-line-cut-mode"`
    - `data-role="line-cut-panel"`
    - `data-role="line-cut-hint"`
    - `data-action="confirm-line-cut"`
    - `data-action="cancel-line-cut"`
    - `data-action="context-open-line-cut"`
- [ ] **Step 2: Run test to verify it fails**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
  - Expected: FAIL on missing straight-line cut hooks.
- [ ] **Step 3: Write minimal implementation**
  - Add the toolbar button, mode action area, and context-menu item to both shared HTML entry files.
  - Keep the panel hidden by default and aligned with the existing inspector structure.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

### Task 2: Add failing structure tests for straight-line cut state and controller hooks

**Files:**
- Modify: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`

- [ ] **Step 1: Write the failing test**
  - Add script assertions for:
    - `lineCutMode:`
    - `lineCutDraft:`
    - `function canLineCutSelectedItem(`
    - `function enterLineCutMode(`
    - `function exitLineCutMode(`
    - `function confirmLineCut(`
    - `function cancelLineCut(`
- [ ] **Step 2: Run test to verify it fails**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
  - Expected: FAIL on missing state or controller hooks.
- [ ] **Step 3: Write minimal implementation**
  - Add empty straight-line cut state fields and no-op controller shells in `canvas_tool.js`.
  - Disable the new mode whenever the selection is not a single unrotated normal image.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

## Chunk 2: Geometry Helpers and Preview Draft

### Task 3: Add failing structure tests for axis-aligned cut helpers

**Files:**
- Modify: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`

- [ ] **Step 1: Write the failing test**
  - Add script assertions for:
    - `function resolveLineCutBaseRect(`
    - `function resolveLineCutOrientation(`
    - `function resolveLineCutOffset(`
    - `function buildAxisAlignedLineCutPreview(`
    - `function splitRectPolygonByLine(`
    - `function validateLineCutPreview(`
- [ ] **Step 2: Run test to verify it fails**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
  - Expected: FAIL on missing geometry and validation hooks.
- [ ] **Step 3: Write minimal implementation**
  - Add helper shells that operate in crop-space coordinates.
  - Keep the preview result shape fixed around `orientation`, `offset`, `polygons`, and `validity`.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

### Task 4: Implement straight-line draft updates and preview rendering

**Files:**
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.css`
- Modify: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`

- [ ] **Step 1: Write the failing test**
  - Add script assertions for:
    - `function updateLineCutDraft(`
    - `function updateLineCutPreview(`
    - `function renderLineCutPreview(`
    - `function renderLineCutDragHandle(`
    - `function canConfirmLineCut(`
  - Add structure assertions for:
    - `data-role="line-cut-preview-overlay"`
    - `data-role="line-cut-drag-handle"`
- [ ] **Step 2: Run test to verify it fails**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
  - Expected: FAIL on missing preview hooks or overlay markers.
- [ ] **Step 3: Write minimal implementation**
  - Render the full vertical or horizontal cut line, two-sided preview fill, and one draggable line handle only for the active source image.
  - Style valid and invalid preview states so the confirm button can follow the preview validity.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

## Chunk 3: Mode Interaction and Line Dragging

### Task 5: Implement one-click creation, Shift orientation switch, and whole-line drag flow

**Files:**
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.css`
- Modify: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`

- [ ] **Step 1: Write the failing test**
  - Add script assertions for:
    - `function placeLineCut(`
    - `function previewLineCutPlacement(`
    - `function startLineCutDrag(`
    - `function handleLineCutDragMove(`
    - `function handleLineCutDragEnd(`
    - `event.shiftKey`
- [ ] **Step 2: Run test to verify it fails**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
  - Expected: FAIL on missing placement or line-drag hooks.
- [ ] **Step 3: Write minimal implementation**
  - Use normal click to place a full vertical line and `Shift + click` to place a full horizontal line.
  - Let the generated line drag only along its own axis.
  - Keep middle mouse reserved for viewport pan and do not re-enable marquee selection inside the mode.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

### Task 6: Wire mode gating, hint text, and cancel behavior

**Files:**
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`
- Modify: `cam_wheel/web_canvas_tool/index.html`
- Modify: `cam_wheel/web_canvas_tool/standalone.html`
- Modify: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`

- [ ] **Step 1: Write the failing test**
  - Add script assertions for:
    - `function updateLineCutPanel(`
    - `function updateLineCutSectionVisibility(`
    - `function handleLineCutCancelFromContext(`
    - `event.key === "Escape"`
- [ ] **Step 2: Run test to verify it fails**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
  - Expected: FAIL on missing panel or cancel hooks.
- [ ] **Step 3: Write minimal implementation**
  - Show clear guidance for unsupported states, ready-to-place mode, and line-drag mode.
  - Make `Esc`, right click, clicking blank space, and switching tools all cancel the draft instead of auto-confirming.
  - Keep crop mode and slice mode mutually exclusive with line-cut mode.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

## Chunk 4: Polygon Item Replacement and Export

### Task 7: Create polygon-image items and replace the source image on confirm

**Files:**
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`
- Modify: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`

- [ ] **Step 1: Write the failing test**
  - Add script assertions for:
    - `type: "polygon-image"`
    - `function createLineCutItems(`
    - `function replaceItemWithLineCutPieces(`
    - `function isPolygonImageItem(`
    - `function computePolygonItemBounds(`
- [ ] **Step 2: Run test to verify it fails**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
  - Expected: FAIL on missing polygon item generation hooks.
- [ ] **Step 3: Write minimal implementation**
  - Convert the two preview polygons into two `polygon-image` items that keep the original source image, crop, and visual footprint.
  - Replace the original item on confirm and select the two new pieces together.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

### Task 8: Extend canvas rendering and export for polygon-image items

**Files:**
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.css`
- Modify: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`

- [ ] **Step 1: Write the failing test**
  - Add script assertions for:
    - `function renderPolygonItem(`
    - `function drawPolygonFrameToCanvas(`
    - `function createPolygonOriginalSizeFrame(`
    - `function buildPolygonExportLayout(`
- [ ] **Step 2: Run test to verify it fails**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
  - Expected: FAIL on missing polygon render or export hooks.
- [ ] **Step 3: Write minimal implementation**
  - Render polygon-backed pieces on the canvas without adding a decorative border.
  - Make selection bounds, `1x`, `2x`, and `原图优先` export handle polygon pieces without compressing the original image density.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

## Chunk 5: Context Menu Integration and Regression Coverage

### Task 9: Extend context-menu behavior for normal images vs polygon pieces

**Files:**
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`
- Modify: `cam_wheel/web_canvas_tool/index.html`
- Modify: `cam_wheel/web_canvas_tool/standalone.html`
- Modify: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`

- [ ] **Step 1: Write the failing test**
  - Add script assertions for:
    - `function canOpenLineCutFromContext(`
    - `function applyContextMenuTargetSelection(`
    - `function contextMenuTargetItemType(`
  - Add structure assertions that the context menu includes:
    - `data-action="context-open-line-cut"`
    - no duplicate line-cut action for polygon pieces
- [ ] **Step 2: Run test to verify it fails**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
  - Expected: FAIL on missing context-menu line-cut hooks.
- [ ] **Step 3: Write minimal implementation**
  - Offer `直线切割` only for a single unrotated normal image.
  - Keep polygon pieces limited to `置顶一层 / 置底一层 / 导出图片 / 删除图片`.
  - Preserve the existing “right click should not leave a selection box behind” behavior.
- [ ] **Step 4: Run test to verify it passes**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`

### Task 10: Update manual checklist and run focused regression verification

**Files:**
- Modify: `docs/manual-test-checklist.md`
- Modify: `cam_wheel/web_canvas_tool/index.html`
- Modify: `cam_wheel/web_canvas_tool/standalone.html`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.js`
- Modify: `cam_wheel/web_canvas_tool/canvas_tool.css`
- Test: `test/cam_wheel/canvas_tool_frontend_structure_test.rb`

- [ ] **Step 1: Update the manual checklist**
  - Add checks for:
    - toolbar and context-menu entry into straight-line cut
    - default click places a vertical line
    - `Shift + click` places a horizontal line
    - dragging the line adjusts its position
    - invalid cut rejection
    - polygon-piece move / rotate / export behavior
    - `原图优先` export preserving source density
- [ ] **Step 2: Run the focused frontend structure test**
  - Run: `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
  - Expected: PASS
- [ ] **Step 3: Run the existing CamWheel frontend regression suite**
  - Run: `for test_file in test/cam_wheel/*_test.rb; do ruby -Itest "$test_file" || exit 1; done`
  - Expected: PASS
- [ ] **Step 4: Run manual browser verification**
  - Run: `python3 -m http.server 8765`
  - Verify in browser: `http://127.0.0.1:8765/cam_wheel/web_canvas_tool/standalone.html`
  - Check the new straight-line cut workflow against `docs/manual-test-checklist.md`.
