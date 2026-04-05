# 3ds Max Viewport Export Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a 3ds Max plugin that exports the current active viewport as JPG through the native preview-capture workflow, while adding composition guides, a timestamped default filename, success feedback, and three access points.

**Architecture:** Implement the first version in `MaxScript` and keep the plugin split by responsibility: one registration layer for toolbar/right-click/panel integration, one export module that wraps the native preview-capture flow, one lightweight guide-overlay module for viewport composition guides, and one rollout/panel module that exposes the controls. The plugin should not replace 3ds Max's own render-size or safe-frame systems, and guides must remain viewport-only, never baked into the final JPG.

**Tech Stack:** 3ds Max, MaxScript, native preview capture/export APIs

---

## Chunk 1: Project Skeleton And Export Contract

### Task 1: Create the plugin folder layout and stub files

**Files:**
- Create: `external/3dsmax_camwheel_viewport_export/CamWheel_ViewportExport.ms`
- Create: `external/3dsmax_camwheel_viewport_export/export.ms`
- Create: `external/3dsmax_camwheel_viewport_export/guides.ms`
- Create: `external/3dsmax_camwheel_viewport_export/panel.ms`
- Create: `external/3dsmax_camwheel_viewport_export/install.txt`
- Create: `docs/manual-test-checklist-3dsmax.md`

- [ ] **Step 1: Write the failing smoke-check note**
  - Add a short section in `install.txt` listing the expected files and installation target so there is an explicit contract for the package structure.
- [ ] **Step 2: Verify the structure is missing**
  - Run: `ls external/3dsmax_camwheel_viewport_export`
  - Expected: directory or files do not exist yet.
- [ ] **Step 3: Create the minimal skeleton**
  - Add the four `.ms` files with header comments and placeholder module entry points.
  - Add `install.txt` with install path notes for user scripts/macros.
- [ ] **Step 4: Verify the structure exists**
  - Run: `find external/3dsmax_camwheel_viewport_export -maxdepth 1 -type f | sort`
  - Expected: all six files are listed.

### Task 2: Define the native export wrapper contract

**Files:**
- Modify: `external/3dsmax_camwheel_viewport_export/export.ms`
- Modify: `docs/manual-test-checklist-3dsmax.md`

- [ ] **Step 1: Write the failing contract checklist**
  - Document in `docs/manual-test-checklist-3dsmax.md` that export must:
    - target the active viewport
    - use native preview capture
    - force frame range `0-0`
    - output JPG
    - default to `scene-name-timestamp.jpg`
- [ ] **Step 2: Verify no export contract exists yet**
  - Run: `rg -n "0-0|timestamp|jpg|active viewport|预览" external/3dsmax_camwheel_viewport_export/export.ms docs/manual-test-checklist-3dsmax.md`
  - Expected: missing or placeholder-only matches.
- [ ] **Step 3: Write the minimal export API shell**
  - Add functions for:
    - deriving default file name
    - requesting save path
    - invoking native single-frame preview export
    - reporting success / cancel / failure
- [ ] **Step 4: Review the contract text**
  - Re-open `export.ms` and `docs/manual-test-checklist-3dsmax.md` to confirm the contract is explicit and aligned with the spec.

## Chunk 2: Native Export Flow

### Task 3: Implement default file naming and save flow

**Files:**
- Modify: `external/3dsmax_camwheel_viewport_export/export.ms`
- Modify: `docs/manual-test-checklist-3dsmax.md`

- [ ] **Step 1: Write the failing behavior note**
  - Add checklist bullets for:
    - saved scene name becomes the filename stem
    - unsaved scenes fall back to `camwheel-YYYYMMDD-HHMMSS.jpg`
    - canceled save does not show an error dialog
- [ ] **Step 2: Verify the note exists and code still lacks implementation**
  - Run: `rg -n "camwheel-|strftime|timestamp|cancel" external/3dsmax_camwheel_viewport_export/export.ms docs/manual-test-checklist-3dsmax.md`
  - Expected: checklist present, implementation incomplete.
- [ ] **Step 3: Implement minimal filename + save logic**
  - Add the timestamp helper.
  - Add scene-name normalization.
  - Add save dialog invocation returning either a file path or a canceled state.
- [ ] **Step 4: Manually inspect for obvious failure paths**
  - Re-open the file and confirm:
    - empty scene names are handled
    - `.jpg` is always appended
    - cancel exits early without throwing.

### Task 4: Implement the native single-frame preview export action

**Files:**
- Modify: `external/3dsmax_camwheel_viewport_export/export.ms`
- Modify: `docs/manual-test-checklist-3dsmax.md`

- [ ] **Step 1: Write the failing manual-check bullets**
  - Add checklist bullets for:
    - active viewport export works
    - native preview flow is used
    - frame range is forced to `0-0`
    - visual style attempts to switch to `Standard`
    - success shows `图片已导出`
- [ ] **Step 2: Verify implementation is still incomplete**
  - Run: `rg -n "Standard|0-0|messageBox|preview|viewport" external/3dsmax_camwheel_viewport_export/export.ms`
  - Expected: partial or missing implementation.
- [ ] **Step 3: Implement the minimal export path**
  - Wrap the native preview-capture workflow in one callable function.
  - Pass the requested file path and single-frame range.
  - Attempt to switch the viewport visual style to `Standard` before export; if that fails, continue with current style.
  - Show success feedback only on actual success.
- [ ] **Step 4: Add a direct debug entry point**
  - Leave one clearly named top-level function such as `CamWheel_ExportActiveViewport()` so the export path can be tested from the MaxScript listener before wiring menus/panels.

## Chunk 3: Toolbar, Right-Click, And Panel Entry Points

### Task 5: Register toolbar and macro entry

**Files:**
- Modify: `external/3dsmax_camwheel_viewport_export/CamWheel_ViewportExport.ms`
- Modify: `external/3dsmax_camwheel_viewport_export/export.ms`
- Modify: `external/3dsmax_camwheel_viewport_export/install.txt`

- [ ] **Step 1: Write the failing install note**
  - Add install steps describing how the macro should appear in 3ds Max customize UI for toolbar binding.
- [ ] **Step 2: Verify macro registration is absent**
  - Run: `rg -n "macroScript|CamWheel 视口导出|category" external/3dsmax_camwheel_viewport_export/*.ms`
  - Expected: missing or placeholder-only.
- [ ] **Step 3: Implement minimal toolbar/macro registration**
  - Add a `macroScript` entry that calls the shared export action.
  - Keep all export logic delegated to the export module.
- [ ] **Step 4: Re-read install steps**
  - Confirm the toolbar binding instructions match the registered macro name and category exactly.

### Task 6: Add right-click menu integration

**Files:**
- Modify: `external/3dsmax_camwheel_viewport_export/CamWheel_ViewportExport.ms`
- Modify: `external/3dsmax_camwheel_viewport_export/guides.ms`
- Modify: `docs/manual-test-checklist-3dsmax.md`

- [ ] **Step 1: Write the failing checklist bullet**
  - Add a bullet stating the right-click menu must expose a `CamWheel` submenu with:
    - `导出当前视口`
    - `显示/隐藏辅助线`
- [ ] **Step 2: Verify no right-click hook exists**
  - Run: `rg -n "menu|quad|CamWheel" external/3dsmax_camwheel_viewport_export/*.ms`
  - Expected: missing or incomplete hook.
- [ ] **Step 3: Implement the minimal right-click action hook**
  - Register the submenu entry.
  - Map export to the shared export action.
  - Map guide visibility to one shared toggle function.
- [ ] **Step 4: Review for duplicated logic**
  - Confirm menu actions only call shared functions and do not clone export or guide-state logic inline.

### Task 7: Build the floating panel rollout

**Files:**
- Modify: `external/3dsmax_camwheel_viewport_export/panel.ms`
- Modify: `external/3dsmax_camwheel_viewport_export/guides.ms`
- Modify: `external/3dsmax_camwheel_viewport_export/CamWheel_ViewportExport.ms`
- Modify: `docs/manual-test-checklist-3dsmax.md`

- [ ] **Step 1: Write the failing checklist bullets**
  - Add bullets stating the panel must contain:
    - export button
    - thirds toggle
    - center-cross toggle
    - diagonal toggle
    - all-on button
    - all-off button
- [ ] **Step 2: Verify panel controls are absent**
  - Run: `rg -n "rollout|三分线|中心线|对角线|全部开启|全部关闭" external/3dsmax_camwheel_viewport_export/*.ms`
  - Expected: missing or placeholder-only.
- [ ] **Step 3: Implement the minimal panel**
  - Add one rollout with the six controls.
  - Route every control to shared guide/export actions.
- [ ] **Step 4: Confirm the panel opens from one named entry point**
  - Leave one callable function such as `CamWheel_ShowPanel()` that can be bound or tested directly.

## Chunk 4: Composition Guide Overlay

### Task 8: Add shared guide-state management

**Files:**
- Modify: `external/3dsmax_camwheel_viewport_export/guides.ms`
- Modify: `external/3dsmax_camwheel_viewport_export/panel.ms`
- Modify: `docs/manual-test-checklist-3dsmax.md`

- [ ] **Step 1: Write the failing checklist bullets**
  - Add bullets for:
    - thirds / center / diagonals can be toggled independently
    - all-on / all-off set the whole state correctly
    - guides remain viewport-only
- [ ] **Step 2: Verify there is no shared guide state yet**
  - Run: `rg -n "show_rule_of_thirds|show_center_cross|show_diagonals|guides_visible" external/3dsmax_camwheel_viewport_export/*.ms`
  - Expected: missing or incomplete state.
- [ ] **Step 3: Implement the minimal state store**
  - Add a lightweight global or namespaced struct for guide visibility.
  - Provide functions for:
    - toggle one guide type
    - toggle all guides
    - request viewport redraw
- [ ] **Step 4: Re-open the file and check naming consistency**
  - Confirm the same state keys are used by menu, panel, and overlay drawing.

### Task 9: Implement viewport overlay drawing

**Files:**
- Modify: `external/3dsmax_camwheel_viewport_export/guides.ms`
- Modify: `docs/manual-test-checklist-3dsmax.md`

- [ ] **Step 1: Write the failing checklist bullets**
  - Add bullets for:
    - thirds lines appear in active viewport
    - center-cross appears in active viewport
    - diagonals appear in active viewport
    - guides are thin lines only, with no frame/border treatment
    - exported JPG does not include guides
- [ ] **Step 2: Verify no overlay draw handler exists**
  - Run: `rg -n "register.*redraw|gw\\.|viewport redraw|draw line" external/3dsmax_camwheel_viewport_export/guides.ms`
  - Expected: missing or placeholder-only.
- [ ] **Step 3: Implement the minimal overlay**
  - Register a viewport redraw callback or equivalent supported overlay hook.
  - Draw guide lines relative to the active viewport extents.
  - Keep the drawing lightweight and avoid scene-node creation.
- [ ] **Step 4: Add one debug toggle path**
  - Leave one direct function to enable or disable overlay redraws so debugging is possible without the panel.

## Chunk 5: Packaging And Verification

### Task 10: Package the plugin for local installation

**Files:**
- Modify: `external/3dsmax_camwheel_viewport_export/install.txt`
- Create: `dist/3dsmax_camwheel_viewport_export/`
- Create: `dist/3dsmax_camwheel_viewport_export.zip`

- [ ] **Step 1: Write the packaging checklist**
  - Update `install.txt` with exact copy/install steps for 3ds Max users.
- [ ] **Step 2: Create the distributable folder**
  - Copy the final `.ms` files and install note into `dist/3dsmax_camwheel_viewport_export/`.
- [ ] **Step 3: Zip the package**
  - Run a zip command to create `dist/3dsmax_camwheel_viewport_export.zip`.
- [ ] **Step 4: Inspect the archive**
  - Run: `unzip -l dist/3dsmax_camwheel_viewport_export.zip`
  - Expected: only the plugin files and install note are present.

### Task 11: Run final verification

**Files:**
- Modify: `external/3dsmax_camwheel_viewport_export/CamWheel_ViewportExport.ms`
- Modify: `external/3dsmax_camwheel_viewport_export/export.ms`
- Modify: `external/3dsmax_camwheel_viewport_export/guides.ms`
- Modify: `external/3dsmax_camwheel_viewport_export/panel.ms`
- Modify: `external/3dsmax_camwheel_viewport_export/install.txt`
- Modify: `docs/manual-test-checklist-3dsmax.md`

- [ ] **Step 1: Run static syntax checks where available**
  - Re-open each `.ms` file and inspect for mismatched brackets, handler names, and obvious syntax issues.
- [ ] **Step 2: Execute manual validation inside 3ds Max**
  - Verify:
    - export works from toolbar
    - export works from right-click menu
    - export works from panel
    - default file name matches the rule
    - success feedback only appears on real success
    - guides show correctly and do not export
- [ ] **Step 3: Record any version-specific caveats**
  - Update `install.txt` if a tested 3ds Max version or workaround needs to be documented.
