## Summary

- add the SketchUp canvas tool entry, dialog bridge, standalone web canvas bundle, and related packaging artifacts
- add the 3ds Max viewport export plugin on the dedicated `codex/3dsmax-viewport-export` branch, including guides, export, panel, toolbar icon support, installer, and release notes
- update repo docs so the top-level project now explains the SketchUp plugin, 3ds Max plugin, and standalone web tool together

## Deliverables

- SketchUp plugin updates
  - `cam_wheel/ui/canvas_tool_bridge.rb`
  - `cam_wheel/ui/canvas_tool_dialog.rb`
  - `cam_wheel/web_canvas_tool/`
  - `cam_wheel/assets/icons/canvas_tool.svg`
- standalone web packages
  - `dist/CamWheel-CanvasTool-Standalone.zip`
  - `dist/CamWheel-CanvasTool-Standalone-1.0.4.zip`
- SketchUp package updates
  - `dist/CamWheel-1.0.3.rbz`
  - `dist/CamWheel-1.0.4.rbz`
- 3ds Max plugin branch
  - branch: `codex/3dsmax-viewport-export`
  - packages: `dist/CamWheel_ViewportExport.mzp`, `dist/3dsmax_camwheel_viewport_export.zip`

## Test Plan

- [x] `ruby -Itest test/cam_wheel/canvas_tool_bridge_test.rb`
- [x] `ruby -Itest test/cam_wheel/canvas_tool_dialog_test.rb`
- [x] `ruby -Itest test/cam_wheel/canvas_tool_frontend_structure_test.rb`
- [x] `ruby -Itest test/cam_wheel/main_tool_reference_test.rb`
- [x] `ruby -Itest test/cam_wheel/main_ui_resolution_test.rb`
- [x] `ruby -Itest test/cam_wheel/version_test.rb`
- [x] `ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb`

## Manual Verification

- [ ] In SketchUp, verify the `拼图画布` toolbar/menu entry opens the canvas tool dialog
- [ ] In the standalone web build, verify image import, snapping, selection export, and slicing behavior
- [ ] In 3ds Max, verify startup does not auto-open the panel
- [ ] In 3ds Max, verify toolbar icon, right-click menu, guide toggles, and JPG export behavior

## Notes

- the 3ds Max plugin remains isolated in its own branch and directory structure
- the repository now intentionally hosts multiple related tools in one place instead of splitting them into separate repos
