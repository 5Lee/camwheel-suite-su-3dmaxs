require_relative "../test_helper"

class CamWheelCanvasToolFrontendStructureTest < Minitest::Test
  def test_shared_frontend_files_exist
    assert File.exist?(entry_file("index.html"))
    assert File.exist?(entry_file("standalone.html"))
    assert File.exist?(entry_file("canvas_tool.js"))
    assert File.exist?(entry_file("canvas_tool.css"))
  end

  def test_both_entry_files_reference_shared_assets
    %w[index.html standalone.html].each do |file_name|
      html = File.read(entry_file(file_name))

      assert_includes html, "canvas_tool.css"
      assert_includes html, "canvas_tool.js"
    end
  end

  def test_both_entry_files_include_canvas_tool_regions
    %w[index.html standalone.html].each do |file_name|
      html = File.read(entry_file(file_name))

      assert_includes html, 'data-role="toolbar"'
      assert_includes html, 'data-role="asset-panel"'
      assert_includes html, 'data-role="canvas-viewport"'
      assert_includes html, 'data-role="properties-panel"'
      assert_includes html, 'data-role="export-controls"'
      assert_includes html, 'data-role="notice-region"'
    end
  end

  def test_both_entry_files_include_core_editing_controls
    %w[index.html standalone.html].each do |file_name|
      html = File.read(entry_file(file_name))

      assert_includes html, 'data-action="pick-images"'
      assert_includes html, 'data-action="bring-forward"'
      assert_includes html, 'data-action="send-backward"'
      assert_includes html, 'data-field="pos-x"'
      assert_includes html, 'data-field="pos-y"'
      assert_includes html, 'data-field="width"'
      assert_includes html, 'data-field="height"'
      assert_includes html, 'data-field="rotation"'
      assert_includes html, 'data-field="crop-x"'
      assert_includes html, 'data-field="crop-y"'
      assert_includes html, 'data-field="crop-width"'
      assert_includes html, 'data-field="crop-height"'
      assert_includes html, 'data-action="reset-crop"'
      assert_includes html, 'data-action="toggle-crop-mode"'
      assert_includes html, 'data-role="crop-mode-hint"'
      assert_includes html, 'data-field="export-format"'
      assert_includes html, 'data-action="export-merged"'
      assert_includes html, 'data-action="export-individual"'
      refute_includes html, 'data-field="export-scale"'
    end
  end

  def test_both_entry_files_include_slicing_ui_hooks
    %w[index.html standalone.html].each do |file_name|
      html = File.read(entry_file(file_name))

      assert_includes html, 'data-action="open-slice-mode"'
      assert_includes html, 'data-role="normal-inspector"'
      assert_includes html, 'data-role="slice-panel"'
      assert_includes html, 'data-role="slice-grid-fields"'
      assert_includes html, 'data-role="slice-guide-fields"'
      assert_includes html, 'data-field="slice-mode"'
      assert_includes html, 'data-field="slice-rows"'
      assert_includes html, 'data-field="slice-cols"'
      assert_includes html, 'data-field="slice-vertical-guides"'
      assert_includes html, 'data-field="slice-horizontal-guides"'
      assert_includes html, 'data-action="add-slice-vertical-guide"'
      assert_includes html, 'data-action="add-slice-horizontal-guide"'
      assert_includes html, 'data-action="clear-slice-vertical-guides"'
      assert_includes html, 'data-action="clear-slice-horizontal-guides"'
      assert_includes html, 'data-action="confirm-slice"'
      assert_includes html, 'data-action="cancel-slice"'
      assert_includes html, 'data-role="slice-hint"'
      assert_includes html, 'data-role="canvas-context-menu"'
      assert_includes html, 'data-action="context-toggle-crop"'
      assert_includes html, 'data-action="context-bring-forward"'
      assert_includes html, 'data-action="context-send-backward"'
      assert_includes html, 'data-action="context-export-selection"'
      assert_includes html, 'data-action="context-delete-item"'
    end
  end

  def test_both_entry_files_include_straight_line_cut_ui_hooks
    %w[index.html standalone.html].each do |file_name|
      html = File.read(entry_file(file_name))

      assert_includes html, 'data-action="open-line-cut-mode"'
      assert_includes html, 'data-role="line-cut-panel"'
      assert_includes html, 'data-role="line-cut-hint"'
      assert_includes html, 'data-action="confirm-line-cut"'
      assert_includes html, 'data-action="cancel-line-cut"'
      assert_includes html, 'data-action="context-open-line-cut"'
    end
  end

  def test_canvas_tool_uses_window_level_drag_listeners_for_re_render_safe_interactions
    script = File.read(entry_file("canvas_tool.js"))

    assert_includes script, 'window.addEventListener("pointermove", handleItemDragMove);'
    assert_includes script, 'window.addEventListener("pointerup", handleItemDragEnd);'
    assert_includes script, 'window.addEventListener("pointercancel", handleItemDragEnd);'
    assert_includes script, 'window.addEventListener("pointermove", handleCropDragMove);'
    assert_includes script, 'window.addEventListener("pointerup", handleCropDragEnd);'
    assert_includes script, 'window.addEventListener("pointercancel", handleCropDragEnd);'
  end

  def test_canvas_items_use_square_corners
    css = File.read(entry_file("canvas_tool.css"))

    assert_includes css, "border-radius: 0;"
    refute_includes css, "border-radius: 14px;"
  end

  def test_canvas_items_do_not_use_a_persistent_frame
    css = File.read(entry_file("canvas_tool.css"))

    assert_includes css, "border: 0;"
    refute_includes css, "border: 2px solid transparent;"
  end

  def test_context_menu_respects_hidden_state
    css = File.read(entry_file("canvas_tool.css"))

    assert_includes css, '.canvas-context-menu[hidden]'
    assert_includes css, "display: none"
  end

  def test_canvas_tool_defines_dual_layer_drag_snapping_hooks
    script = File.read(entry_file("canvas_tool.js"))

    assert_includes script, "const SNAP_THRESHOLD ="
    assert_includes script, "const GRID_SIZE ="
    assert_includes script, "function applyDragSnapping("
    assert_includes script, "function snapToItems("
    assert_includes script, "function snapToGrid("
  end

  def test_canvas_tool_defines_middle_mouse_pan_and_snap_guide_hooks
    script = File.read(entry_file("canvas_tool.js"))

    assert_includes script, "snapGuides:"
    assert_includes script, "event.button === 1"
    assert_includes script, "function startViewportPan("
    assert_includes script, "function setSnapGuides("
    assert_includes script, "function clearSnapGuides("
  end

  def test_canvas_tool_defines_roomier_import_defaults
    script = File.read(entry_file("canvas_tool.js"))

    assert_includes script, "const INITIAL_ITEM_MAX_SIZE ="
    assert_includes script, "const IMPORT_OFFSET_STEP ="
    assert_includes script, "URL.createObjectURL(file)"
    refute_includes script, "width: Math.max(120, Math.round(img.width / 2))"
    refute_includes script, "height: Math.max(120, Math.round(img.height / 2))"
    refute_includes script, "x: 60 + index * 28"
    refute_includes script, "y: 60 + index * 28"
    refute_includes script, "const dataUrl = await readAsDataUrl(file);"
  end

  def test_canvas_tool_defines_marquee_selection_and_multi_selection_state
    script = File.read(entry_file("canvas_tool.js"))

    assert_includes script, "activeSelection:"
    assert_includes script, "selectedIds:"
    assert_includes script, "marqueeSelection:"
    assert_includes script, "function startMarqueeSelection("
    assert_includes script, "function updateMarqueeSelection("
    assert_includes script, "function finalizeMarqueeSelection("
    assert_includes script, "function moveSelectedItems("
  end

  def test_canvas_tool_defines_selection_based_export_hooks
    script = File.read(entry_file("canvas_tool.js"))

    assert_includes script, "function selectedItems("
    assert_includes script, "function computeSelectedBounds("
    assert_includes script, "function renderExportSelectionBounds("
    assert_includes script, "function exportSelectedAsMergedImage("
    assert_includes script, "function exportSelectedAsSeparateImages("
    assert_includes script, "function buildSingleItemExportLayout("
    assert_includes script, 'data-action="export-merged"'
    assert_includes script, 'data-action="export-individual"'
    refute_includes script, "exportScale:"
    refute_includes script, "function resolveExportScaleFactor("
    refute_includes script, "refs.exportScale"
    assert_includes script, 'data-role="export-selection-bounds"'
  end

  def test_canvas_tool_defines_original_size_export_layout_hooks
    script = File.read(entry_file("canvas_tool.js"))

    assert_includes script, "function buildExportLayout("
    assert_includes script, "function buildOriginalSizeExportLayout("
    assert_includes script, "function exportItemsWithLayout("
    assert_includes script, "function createOriginalSizeFrame("
  end

  def test_canvas_tool_defines_slice_state_and_helper_hooks
    script = File.read(entry_file("canvas_tool.js"))

    assert_includes script, "sliceMode:"
    assert_includes script, "sliceDraft:"
    assert_includes script, "function canSliceSelectedItem("
    assert_includes script, "function updateSlicePanel("
    assert_includes script, "function updateSliceSectionVisibility("
    assert_includes script, "function canConfirmSlice("
    assert_includes script, "function enterSliceMode("
    assert_includes script, "function exitSliceMode("
    assert_includes script, "function buildGridSliceRects("
    assert_includes script, "function buildGuideSliceRects("
    assert_includes script, "function createSliceItems("
  end

  def test_canvas_tool_defines_right_click_context_menu_hooks
    script = File.read(entry_file("canvas_tool.js"))

    assert_includes script, "function openContextMenu("
    assert_includes script, "function closeContextMenu("
    assert_includes script, "function updateContextMenuState("
    assert_includes script, "function executeContextMenuAction("
    assert_includes script, "function handleItemContextMenu("
    assert_includes script, "function contextMenuTargetItem("
    assert_includes script, "event.button === 2"
    assert_includes script, 'data-action="context-open-slice"'
    assert_includes script, 'data-action="context-toggle-crop"'
    assert_includes script, 'data-action="context-bring-forward"'
    assert_includes script, 'data-action="context-send-backward"'
    assert_includes script, 'data-action="context-export-selection"'
    assert_includes script, 'data-action="context-delete-item"'
  end

  def test_context_menu_js_explicitly_toggles_display_state
    script = File.read(entry_file("canvas_tool.js"))

    assert_includes script, 'refs.contextMenu.style.display = "grid"'
    assert_includes script, 'refs.contextMenu.style.display = "none"'
  end

  def test_canvas_tool_defines_zoom_anchor_hooks
    script = File.read(entry_file("canvas_tool.js"))

    assert_includes script, 'event.deltaY < 0 ? 1.1 : 0.9'
    assert_includes script, "function zoomViewportAt("
    assert_includes script, "function resolveZoomAnchorWorldPoint("
    assert_includes script, "function clientPointToWorld("
  end

  def test_canvas_tool_defines_grid_slice_preview_hooks
    script = File.read(entry_file("canvas_tool.js"))

    assert_includes script, "function normalizeSliceGrid("
    assert_includes script, "function resolveSliceBaseRect("
    assert_includes script, "function buildGridSliceRects("
    assert_includes script, "function updateSliceDraftFromGrid("
    assert_includes script, "function renderSlicePreview("
    assert_includes script, 'data-role="slice-preview-overlay"'
    assert_includes script, 'data-role="slice-preview-count"'
  end

  def test_canvas_tool_defines_guide_slice_and_confirmation_hooks
    script = File.read(entry_file("canvas_tool.js"))

    assert_includes script, "pendingGuideAxis:"
    assert_includes script, "function parseGuideList("
    assert_includes script, "function normalizeGuidePositions("
    assert_includes script, "function buildGuideSliceRects("
    assert_includes script, "function requestSliceGuidePlacement("
    assert_includes script, "function addSliceGuide("
    assert_includes script, "function handleSlicePreviewPointerDown("
    assert_includes script, "function startGuideDrag("
    assert_includes script, "function handleGuideDragMove("
    assert_includes script, "function handleGuideDragEnd("
    assert_includes script, "function syncGuideInputs("
    assert_includes script, "function clearSliceGuides("
    assert_includes script, "function selectedSliceSourceItem("
    assert_includes script, "function removeItemById("
    assert_includes script, "function replaceItemWithSlices("
    assert_includes script, "function confirmSlice("
    assert_includes script, "function cancelSlice("
    assert_includes script, "function showNotice("
    assert_includes script, "切片已完成"
  end

  def test_canvas_tool_defines_straight_line_cut_state_and_controller_hooks
    script = File.read(entry_file("canvas_tool.js"))

    assert_includes script, "lineCutMode:"
    assert_includes script, "lineCutDraft:"
    assert_includes script, "function canLineCutSelectedItem("
    assert_includes script, "function enterLineCutMode("
    assert_includes script, "function exitLineCutMode("
    assert_includes script, "function confirmLineCut("
    assert_includes script, "function cancelLineCut("
  end

  def test_canvas_tool_defines_straight_line_cut_geometry_helpers
    script = File.read(entry_file("canvas_tool.js"))

    assert_includes script, "function resolveLineCutBaseRect("
    assert_includes script, "function resolveLineCutOrientation("
    assert_includes script, "function resolveLineCutOffset("
    assert_includes script, "function buildAxisAlignedLineCutPreview("
    assert_includes script, "function splitRectPolygonByLine("
    assert_includes script, "function validateLineCutPreview("
  end

  def test_canvas_tool_defines_straight_line_cut_preview_hooks
    script = File.read(entry_file("canvas_tool.js"))

    assert_includes script, "function updateLineCutDraft("
    assert_includes script, "function updateLineCutPreview("
    assert_includes script, "function renderLineCutPreview("
    assert_includes script, "function renderLineCutPreviewLine("
    assert_includes script, "function renderLineCutDragHandle("
    assert_includes script, "function canConfirmLineCut("
    assert_includes script, 'data-role="line-cut-preview-overlay"'
    assert_includes script, 'data-role="line-cut-drag-handle"'
    assert_includes script, "if (state.lineCutDraft.placed)"
  end

  def test_canvas_tool_initializes_axis_aligned_line_cut_draft
    script = File.read(entry_file("canvas_tool.js"))

    assert_includes script, 'orientation: "vertical"'
    assert_includes script, "offset: null"
    assert_includes script, "placed: false"
    assert_includes script, "isDragging: false"
    assert_includes script, 'preview: buildAxisAlignedLineCutPreview(selectedItem(), "vertical", null)'
    refute_includes script, 'phase: "pick-start"'
    refute_includes script, "buildLineCutPreview(null, null)"
  end

  def test_canvas_tool_defines_straight_line_cut_interaction_hooks
    script = File.read(entry_file("canvas_tool.js"))

    assert_includes script, "function placeLineCut("
    assert_includes script, "function previewLineCutPlacement("
    assert_includes script, "function startLineCutDrag("
    assert_includes script, "function handleLineCutDragMove("
    assert_includes script, "function handleLineCutDragEnd("
    assert_includes script, "event.shiftKey"
    assert_includes script, 'window.addEventListener("pointermove", handleLineCutDragMove);'
    assert_includes script, 'window.addEventListener("pointerup", handleLineCutDragEnd);'
    assert_includes script, 'window.addEventListener("pointercancel", handleLineCutDragEnd);'
    assert_includes script, 'window.removeEventListener("pointermove", handleLineCutDragMove);'
  end

  def test_canvas_tool_styles_line_cut_drag_handle_as_full_axis_handle
    css = File.read(entry_file("canvas_tool.css"))

    assert_includes css, ".line-cut-drag-handle"
    assert_includes css, ".line-cut-drag-handle.is-vertical"
    assert_includes css, ".line-cut-drag-handle.is-horizontal"
    refute_includes css, ".line-cut-handle"
  end

  def test_canvas_tool_defines_straight_line_cut_panel_and_cancel_hooks
    script = File.read(entry_file("canvas_tool.js"))

    assert_includes script, "function updateLineCutPanel("
    assert_includes script, "function updateLineCutSectionVisibility("
    assert_includes script, "function handleLineCutCancelFromContext("
    assert_includes script, 'event.key === "Escape"'
  end

  def test_canvas_tool_defines_polygon_item_generation_hooks
    script = File.read(entry_file("canvas_tool.js"))

    assert_includes script, 'type: "polygon-image"'
    assert_includes script, "function createLineCutItems("
    assert_includes script, "function replaceItemWithLineCutPieces("
    assert_includes script, "function isPolygonImageItem("
    assert_includes script, "function computePolygonItemBounds("
  end

  def test_canvas_tool_defines_polygon_render_and_export_hooks
    script = File.read(entry_file("canvas_tool.js"))

    assert_includes script, "function renderPolygonItem("
    assert_includes script, "function drawPolygonFrameToCanvas("
    assert_includes script, "function createPolygonOriginalSizeFrame("
    assert_includes script, "function buildPolygonExportLayout("
  end

  def test_canvas_tool_defines_line_cut_context_menu_hooks
    script = File.read(entry_file("canvas_tool.js"))

    assert_includes script, "function canOpenLineCutFromContext("
    assert_includes script, "function contextMenuTargetItemType("
    assert_includes script, 'data-action="context-open-line-cut"'
  end

  private

  def entry_file(name)
    File.expand_path("../../cam_wheel/web_canvas_tool/#{name}", __dir__)
  end
end
