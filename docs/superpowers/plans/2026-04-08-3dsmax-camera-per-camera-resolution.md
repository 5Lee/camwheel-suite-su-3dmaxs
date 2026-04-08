# 3ds Max Camera Per-Camera Resolution Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为 3ds Max 插件的每个相机增加独立的比例预设、宽度和高度设置，并让批量导出按各自参数输出。

**Architecture:** 继续沿用现有职责边界：`export.ms` 负责相机导出参数的读取、保存与应用，`panel.ms` 负责左侧当前选中相机设置与右侧列表摘要同步，`guides.ms` 继续只负责辅助线状态。相机参数复用与辅助线同样的本地持久化思路，但键空间独立。

**Tech Stack:** MAXScript、3ds Max INI API、Rollout UI、Ruby + Minitest 结构测试。

---

## File Map

- Modify: `external/3dsmax_camwheel_viewport_export/export.ms`
  - 新增相机独立导出参数读写、默认值解析、导出前应用
- Modify: `external/3dsmax_camwheel_viewport_export/panel.ms`
  - 左侧新增“当前选中相机设置”，右侧列表显示摘要，切换相机时同步编辑区
- Modify: `external/3dsmax_camwheel_viewport_export/README.md`
  - 增加每个相机独立比例/分辨率说明
- Modify: `external/3dsmax_camwheel_viewport_export/install.txt`
  - 增加相机独立设置说明
- Modify: `docs/manual-test-checklist-3dsmax.md`
  - 增加相机参数持久化和不同分辨率批量导出手测项
- Modify: `test/external/3dsmax_viewport_export_structure_test.rb`
  - 先补失败测试，再改实现

---

## Chunk 1: 相机独立导出设置核心

### Task 1: 为 `export.ms` 补失败测试

**Files:**
- Modify: `test/external/3dsmax_viewport_export_structure_test.rb`
- Modify: `external/3dsmax_camwheel_viewport_export/export.ms`

- [ ] **Step 1: 添加失败测试**

在 `test_export_script_defines_native_export_hooks` 中补断言：

```ruby
assert_includes script, "CamWheel_GetDefaultCameraExportSettings"
assert_includes script, "CamWheel_GetCameraExportSettings"
assert_includes script, "CamWheel_SaveCameraExportSettings"
assert_includes script, "CamWheel_ApplyCameraExportSettings"
assert_includes script, "camera."
assert_includes script, "aspect_preset"
assert_includes script, "width"
assert_includes script, "height"
```

- [ ] **Step 2: 运行测试确认先失败**

Run: `ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb`

Expected: FAIL，提示 `export.ms` 尚未包含相机独立导出参数逻辑。

- [ ] **Step 3: 写最小实现**

在 `export.ms` 中新增：

```maxscript
fn CamWheel_GetDefaultCameraExportSettings = (...)
fn CamWheel_GetCameraExportSettings cameraNode = (...)
fn CamWheel_SaveCameraExportSettings cameraNode presetLabel widthValue heightValue = (...)
fn CamWheel_ApplyCameraExportSettings cameraNode = (...)
```

要求：

- 默认值来自当前全局渲染设置
- 配置按相机名保存
- 保存内容至少包含：
  - `aspect_preset`
  - `width`
  - `height`

- [ ] **Step 4: 接入批量导出前应用逻辑**

在 `CamWheel_ExportViewportForCamera` 或调用链中加入：

- 读取当前相机设置
- 应用 `renderWidth`
- 应用 `renderHeight`
- 同步渲染比例

- [ ] **Step 5: 运行测试确认转绿**

Run: `ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb`

Expected: PASS，或失败点转移到 UI 契约。

- [ ] **Step 6: 提交核心逻辑**

```bash
git add test/external/3dsmax_viewport_export_structure_test.rb external/3dsmax_camwheel_viewport_export/export.ms
git commit -m "feat: add per-camera export settings core"
```

---

## Chunk 2: 左侧当前相机设置与右侧摘要列表

### Task 2: 为 `panel.ms` 补失败测试

**Files:**
- Modify: `test/external/3dsmax_viewport_export_structure_test.rb`
- Modify: `external/3dsmax_camwheel_viewport_export/panel.ms`

- [ ] **Step 1: 添加失败测试**

补断言：

```ruby
assert_includes script, "当前选中相机设置"
assert_includes script, "CamWheel_PanelSelectedCameraIndex"
assert_includes script, "CamWheel_PanelSyncSelectedCameraSettings"
assert_includes script, "CamWheel_PanelApplySelectedCameraSettings"
assert_includes script, "CamWheel_PanelFormatCameraListItem"
assert_includes script, "应用到当前相机"
```

- [ ] **Step 2: 运行测试确认先失败**

Run: `ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb`

Expected: FAIL，提示 `panel.ms` 还没有当前相机设置区。

- [ ] **Step 3: 新增左侧当前相机设置 UI**

在左侧新增：

- 当前相机名称标签
- 比例预设下拉
- 宽度输入
- 高度输入
- `应用到当前相机` 按钮

- [ ] **Step 4: 新增当前相机同步函数**

实现：

```maxscript
global CamWheel_PanelSelectedCameraIndex
fn CamWheel_PanelSyncSelectedCameraSettings = (...)
fn CamWheel_PanelApplySelectedCameraSettings = (...)
fn CamWheel_PanelFormatCameraListItem cameraNode = (...)
```

要求：

- 选中右侧相机时，左侧同步该相机设置
- 点“应用到当前相机”后保存
- 右侧摘要立即刷新

- [ ] **Step 5: 接入右侧列表选择事件**

要求：

- 用户点击右侧相机项时，记录当前选中项
- 左侧显示该相机名字、比例和宽高

- [ ] **Step 6: 运行测试确认通过**

Run: `ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb`

Expected: PASS。

- [ ] **Step 7: 提交 UI 改动**

```bash
git add test/external/3dsmax_viewport_export_structure_test.rb external/3dsmax_camwheel_viewport_export/panel.ms
git commit -m "feat: add per-camera export settings panel"
```

---

## Chunk 3: 文档与回归

### Task 3: 同步文档和手测

**Files:**
- Modify: `external/3dsmax_camwheel_viewport_export/README.md`
- Modify: `external/3dsmax_camwheel_viewport_export/install.txt`
- Modify: `docs/manual-test-checklist-3dsmax.md`
- Modify: `test/external/3dsmax_viewport_export_structure_test.rb`

- [ ] **Step 1: 为文档补失败测试**

补断言：

```ruby
assert_includes notes, "当前选中相机设置"
assert_includes notes, "应用到当前相机"
assert_includes notes, "每个相机独立"
assert_includes notes, "比例预设 + 宽度 + 高度"
```

- [ ] **Step 2: 运行测试确认先失败**

Run: `ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb`

Expected: FAIL。

- [ ] **Step 3: 更新文档**

同步说明：

- 每个相机独立的比例和分辨率
- 左侧当前相机设置区
- 右侧列表摘要
- 批量导出按每个相机自己的参数执行

- [ ] **Step 4: 运行完整结构测试**

Run: `ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb`

Expected: PASS。

- [ ] **Step 5: 提交文档**

```bash
git add external/3dsmax_camwheel_viewport_export/README.md external/3dsmax_camwheel_viewport_export/install.txt docs/manual-test-checklist-3dsmax.md test/external/3dsmax_viewport_export_structure_test.rb
git commit -m "docs: add per-camera export settings notes"
```

