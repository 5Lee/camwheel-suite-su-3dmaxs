# 3ds Max Camera Batch Export Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 3ds Max 控制面板中增加相机读取、手动勾选与批量截图导出能力，并保持现有单张导出与辅助线逻辑可用。

**Architecture:** 继续沿用当前插件的三段式结构：`export.ms` 负责导出与文件名逻辑，`panel.ms` 负责交互与状态同步，`CamWheel_ViewportExport.ms` 只保留加载与入口注册。批量导出复用现有 `createPreview` 能力，在每个相机导出前切换视口、临时隐藏辅助线、导出完成后恢复状态。

**Tech Stack:** MAXScript、3ds Max 原生 `createPreview`、Rollout UI、必要时使用 `.NET CheckedListBox` 承载多选勾选列表、Ruby + Minitest 结构测试。

---

## File Map

- Modify: `external/3dsmax_camwheel_viewport_export/export.ms`
  - 增加相机枚举、批量文件名、唯一文件路径、批量执行与汇总提示
- Modify: `external/3dsmax_camwheel_viewport_export/panel.ms`
  - 把面板改为宽版双列，增加相机列表、多选操作与批量导出按钮
- Modify: `external/3dsmax_camwheel_viewport_export/README.md`
  - 增加批量截图功能说明和使用步骤
- Modify: `external/3dsmax_camwheel_viewport_export/install.txt`
  - 增加批量截图入口和命名规则说明
- Modify: `docs/manual-test-checklist-3dsmax.md`
  - 增加相机列表、批量导出、重名后缀、失败继续等手测项
- Modify: `test/external/3dsmax_viewport_export_structure_test.rb`
  - 先补结构契约测试，再改实现

---

## Chunk 1: 批量导出核心

### Task 1: 为导出核心补结构契约测试

**Files:**
- Modify: `test/external/3dsmax_viewport_export_structure_test.rb`
- Test: `test/external/3dsmax_viewport_export_structure_test.rb`

- [ ] **Step 1: 添加导出核心的失败测试**

在 `test_export_script_defines_native_export_hooks` 附近补断言，至少覆盖：

```ruby
assert_includes script, "global CamWheel_GetSceneCameras"
assert_includes script, "global CamWheel_RequestBatchExportDirectory"
assert_includes script, "global CamWheel_ExportSelectedCameras"
assert_includes script, "CamWheel_BuildBatchExportFilename"
assert_includes script, "CamWheel_ResolveUniqueExportPath"
assert_includes script, "场景名-相机名"
assert_includes script, "导出选中相机"
```

- [ ] **Step 2: 运行测试确认先失败**

Run: `ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb`

Expected: FAIL，提示 `export.ms` 尚未定义新的批量导出函数或命名契约字符串。

- [ ] **Step 3: 在 `export.ms` 中写最小实现**

补全以下全局声明与函数骨架，并先让测试转绿：

```maxscript
global CamWheel_GetSceneCameras
global CamWheel_RequestBatchExportDirectory
global CamWheel_ExportSelectedCameras

fn CamWheel_GetSceneCameras = (...)
fn CamWheel_SanitizeExportNamePart value = (...)
fn CamWheel_BuildBatchExportFilename cameraName = (...)
fn CamWheel_ResolveUniqueExportPath directory filename = (...)
fn CamWheel_RequestBatchExportDirectory = (...)
```

实现要求：

- `CamWheel_GetSceneCameras()` 返回场景相机节点数组，顺序稳定
- 文件名生成为 `场景名-相机名.jpg`
- 文件名非法字符统一替换
- 目标文件已存在时自动追加 `-2`、`-3`

- [ ] **Step 4: 完成逐相机导出与汇总函数**

在 `export.ms` 中继续补：

```maxscript
fn CamWheel_ExportViewportForCamera cameraNode exportPath = (...)
fn CamWheel_ExportSelectedCameras cameraNodes exportDirectory = (...)
```

行为要求：

- 切换活动视口到相机
- 暂时关闭 `#guides_visible`
- 调用 `CamWheel_RunNativePreviewExport`
- 失败时记录，不中断整批任务
- 返回统计结构，至少包含成功数、失败数、目录、失败名单

- [ ] **Step 5: 再次运行结构测试**

Run: `ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb`

Expected: PASS，或至少当前失败点已经从 `export.ms` 转移到尚未完成的 UI 契约。

- [ ] **Step 6: 提交导出核心**

```bash
git add test/external/3dsmax_viewport_export_structure_test.rb external/3dsmax_camwheel_viewport_export/export.ms
git commit -m "feat: add 3dsmax camera batch export core"
```

---

## Chunk 2: 面板相机列表与批量交互

### Task 2: 为宽版面板与相机列表补失败测试

**Files:**
- Modify: `test/external/3dsmax_viewport_export_structure_test.rb`
- Test: `test/external/3dsmax_viewport_export_structure_test.rb`

- [ ] **Step 1: 添加面板 UI 的失败测试**

补断言覆盖：

```ruby
assert_includes script, "刷新列表"
assert_includes script, "全选"
assert_includes script, "反选"
assert_includes script, "批量导出选中相机"
assert_includes script, "相机批量截图"
assert_includes script, "dotNetControl"
assert_includes script, "CheckedListBox"
assert_includes script, "createDialog CamWheelPanelRollout 420 390"
```

- [ ] **Step 2: 运行测试确认先失败**

Run: `ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb`

Expected: FAIL，提示 `panel.ms` 还没有批量相机 UI 或宽版面板尺寸。

- [ ] **Step 3: 在 `panel.ms` 中增加相机状态与 UI 布局**

新增面板级状态：

```maxscript
global CamWheel_PanelCameraNodes
global CamWheel_PanelBatchStatusText
```

布局要求：

- 保持左侧现有分辨率 / 导出 / 辅助线区
- 右侧新增相机批量区
- 面板宽度改为约 `420`
- 高度保持 `390` 左右

列表实现要求：

- 优先使用 `dotNetControl cameraList "System.Windows.Forms.CheckedListBox"`
- 打开面板时自动加载相机
- 支持 `刷新列表`、`全选`、`反选`
- 支持读取勾选后的相机节点数组

- [ ] **Step 4: 接入批量导出按钮事件**

在 `panel.ms` 中补：

```maxscript
fn CamWheel_PanelRefreshCameraList = (...)
fn CamWheel_PanelSelectAllCameras = (...)
fn CamWheel_PanelInvertCameraSelection = (...)
fn CamWheel_PanelGetSelectedCameras = (...)
```

按钮行为：

- 无勾选时提示“请先选择相机”
- 点击批量导出时调用 `CamWheel_RequestBatchExportDirectory()`
- 调用 `CamWheel_ExportSelectedCameras`
- 把统计结果写回状态文本

- [ ] **Step 5: 运行结构测试**

Run: `ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb`

Expected: PASS，结构测试全部通过。

- [ ] **Step 6: 手动检查语法级风险**

重点自检：

- `dotNetControl` 初始化位置是否在 rollout 内合法
- `on CamWheelPanelRollout open do` 中对列表填充是否先清空再写入
- 宽版布局是否没有遮挡现有控件

- [ ] **Step 7: 提交面板交互**

```bash
git add test/external/3dsmax_viewport_export_structure_test.rb external/3dsmax_camwheel_viewport_export/panel.ms
git commit -m "feat: add 3dsmax camera batch export panel"
```

---

## Chunk 3: 文档与手测闭环

### Task 3: 更新说明文档与手测清单

**Files:**
- Modify: `external/3dsmax_camwheel_viewport_export/README.md`
- Modify: `external/3dsmax_camwheel_viewport_export/install.txt`
- Modify: `docs/manual-test-checklist-3dsmax.md`
- Test: `test/external/3dsmax_viewport_export_structure_test.rb`

- [ ] **Step 1: 为文档补失败测试**

在结构测试中补文档断言，例如：

```ruby
assert_includes notes, "批量导出选中相机"
assert_includes notes, "场景名-相机名.jpg"
assert_includes notes, "全选"
assert_includes notes, "反选"
assert_includes notes, "刷新列表"
assert_includes notes, "重名"
```

- [ ] **Step 2: 运行测试确认先失败**

Run: `ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb`

Expected: FAIL，提示 README / install / checklist 尚未同步。

- [ ] **Step 3: 更新文档**

同步以下内容：

- README：增加批量截图能力、使用步骤、命名规则
- install.txt：说明入口、勾选流程、文件夹选择、重名后缀
- 手测清单：新增多相机、空相机、取消目录、失败继续、重名处理、辅助线不导出

- [ ] **Step 4: 运行结构测试**

Run: `ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb`

Expected: PASS。

- [ ] **Step 5: 执行完整结构测试回归**

Run: `ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb`

Expected: PASS，无新增断言失败。

- [ ] **Step 6: 记录 3ds Max 手测动作**

手测顺序：

1. 打开面板，确认相机列表自动读取
2. 点击 `刷新列表`，确认新增 / 删除相机后列表刷新
3. 使用 `全选` / `反选`
4. 批量导出 2~3 个相机，确认命名为 `场景名-相机名.jpg`
5. 重复导出同批相机，确认生成 `-2` 后缀
6. 确认导出图片不带辅助线
7. 确认单张导出仍然正常

- [ ] **Step 7: 提交文档同步**

```bash
git add external/3dsmax_camwheel_viewport_export/README.md external/3dsmax_camwheel_viewport_export/install.txt docs/manual-test-checklist-3dsmax.md test/external/3dsmax_viewport_export_structure_test.rb
git commit -m "docs: document 3dsmax camera batch export"
```

---

## Chunk 4: 最终验证与打包准备

### Task 4: 做交付前检查

**Files:**
- Modify: 如实现过程中有必要的轻微修正，仅限上述文件

- [ ] **Step 1: 查看工作区差异**

Run: `git status --short`

Expected: 只出现本次功能相关文件与已知未跟踪临时目录。

- [ ] **Step 2: 运行结构测试**

Run: `ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb`

Expected: PASS。

- [ ] **Step 3: 检查是否需要同步 `dist/`**

仅在功能确认无误后再更新：

- `dist/CamWheel_ViewportExport.mzp`
- `dist/3dsmax_camwheel_viewport_export.zip`

- [ ] **Step 4: 整理交付说明**

交付时说明：

- 改了哪些文件
- 新增哪些 UI 操作
- 需要在 3ds Max 中如何手测
- 是否已准备好进入打包步骤

