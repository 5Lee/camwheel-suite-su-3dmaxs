# 3ds Max Guides Default Off Persistence Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让 3ds Max 插件首次启动时默认关闭辅助线，并在后续启动时记住用户上一次的四个辅助线开关状态。

**Architecture:** 继续以 `guides.ms` 作为辅助线状态单一来源，在该文件内增加默认状态、INI 持久化读写与统一的“设置并保存”入口。`panel.ms` 和宏切换逻辑不再直接只改内存状态，而是走持久化入口，这样面板交互与右键/工具栏宏都能统一保存。

**Tech Stack:** MAXScript、3ds Max INI API（`getINISetting` / `setINISetting`）、Ruby + Minitest 结构测试。

---

## File Map

- Modify: `external/3dsmax_camwheel_viewport_export/guides.ms`
  - 增加默认状态、INI 文件路径、加载与保存函数、统一持久化入口
- Modify: `external/3dsmax_camwheel_viewport_export/panel.ms`
  - 面板里的四个辅助线开关改为调用持久化入口
- Modify: `external/3dsmax_camwheel_viewport_export/README.md`
  - 说明首次默认关闭与状态记忆
- Modify: `external/3dsmax_camwheel_viewport_export/install.txt`
  - 说明首次默认关闭与记忆行为
- Modify: `docs/manual-test-checklist-3dsmax.md`
  - 增加删除状态文件、重启验证、宏切换验证
- Modify: `test/external/3dsmax_viewport_export_structure_test.rb`
  - 先补失败测试，再改实现

---

## Chunk 1: 辅助线持久化核心

### Task 1: 为 `guides.ms` 补失败测试

**Files:**
- Modify: `test/external/3dsmax_viewport_export_structure_test.rb`
- Test: `test/external/3dsmax_viewport_export_structure_test.rb`

- [ ] **Step 1: 添加失败测试**

在 `test_guide_script_defines_overlay_state_and_toggle_hooks` 中补至少这些断言：

```ruby
assert_includes script, "CamWheel_GuideStateFilePath"
assert_includes script, "CamWheel_DefaultGuideState"
assert_includes script, "CamWheel_LoadGuideState"
assert_includes script, "CamWheel_SaveGuideState"
assert_includes script, "CamWheel_SetGuideStateAndPersist"
assert_includes script, "getINISetting"
assert_includes script, "setINISetting"
assert_includes script, "#guides_visible, false"
```

- [ ] **Step 2: 运行测试确认先失败**

Run: `ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb`

Expected: FAIL，提示 `guides.ms` 尚未包含持久化契约。

- [ ] **Step 3: 写最小实现**

在 `guides.ms` 中新增：

```maxscript
global CamWheel_GuideStateFilePath

fn CamWheel_DefaultGuideState = (...)
fn CamWheel_LoadGuideState = (...)
fn CamWheel_SaveGuideState = (...)
fn CamWheel_SetGuideStateAndPersist key value = (...)
```

实现要求：

- 默认状态为：
  - `#guides_visible, false`
  - `#show_rule_of_thirds, true`
  - `#show_center_cross, false`
  - `#show_diagonals, false`
- 使用 `CamWheel_ScriptRoot` 生成 `camwheel_guides_state.ini`
- 启动时先读 INI，读不到时回退默认值

- [ ] **Step 4: 接入切换入口**

在 `guides.ms` 中把以下逻辑改为走持久化入口：

- `CamWheel_ToggleGuides`
- `CamWheel_SetAllGuides`（若仍保留）
- 任何直接修改 `#guides_visible` 的逻辑

- [ ] **Step 5: 运行测试确认转绿**

Run: `ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb`

Expected: PASS，或失败点只剩面板调用尚未切换。

- [ ] **Step 6: 提交核心持久化**

```bash
git add test/external/3dsmax_viewport_export_structure_test.rb external/3dsmax_camwheel_viewport_export/guides.ms
git commit -m "feat: persist 3dsmax guide state"
```

---

## Chunk 2: 面板改为持久化入口

### Task 2: 为面板辅助线开关补失败测试

**Files:**
- Modify: `test/external/3dsmax_viewport_export_structure_test.rb`
- Modify: `external/3dsmax_camwheel_viewport_export/panel.ms`

- [ ] **Step 1: 添加失败测试**

为 `panel.ms` 补断言：

```ruby
assert_includes script, "CamWheel_SetGuideStateAndPersist #guides_visible state"
assert_includes script, "CamWheel_SetGuideStateAndPersist #show_rule_of_thirds state"
assert_includes script, "CamWheel_SetGuideStateAndPersist #show_center_cross state"
assert_includes script, "CamWheel_SetGuideStateAndPersist #show_diagonals state"
```

- [ ] **Step 2: 运行测试确认先失败**

Run: `ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb`

Expected: FAIL，提示 `panel.ms` 仍在直接调用 `CamWheel_SetGuideState`。

- [ ] **Step 3: 修改面板开关事件**

把四个事件处理器切到：

```maxscript
CamWheel_SetGuideStateAndPersist #guides_visible state
CamWheel_SetGuideStateAndPersist #show_rule_of_thirds state
CamWheel_SetGuideStateAndPersist #show_center_cross state
CamWheel_SetGuideStateAndPersist #show_diagonals state
```

- [ ] **Step 4: 运行测试确认通过**

Run: `ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb`

Expected: PASS。

- [ ] **Step 5: 提交面板接线**

```bash
git add test/external/3dsmax_viewport_export_structure_test.rb external/3dsmax_camwheel_viewport_export/panel.ms
git commit -m "feat: persist 3dsmax guide toggles from panel"
```

---

## Chunk 3: 文档与回归

### Task 3: 更新说明与手测清单

**Files:**
- Modify: `external/3dsmax_camwheel_viewport_export/README.md`
- Modify: `external/3dsmax_camwheel_viewport_export/install.txt`
- Modify: `docs/manual-test-checklist-3dsmax.md`
- Modify: `test/external/3dsmax_viewport_export_structure_test.rb`

- [ ] **Step 1: 为文档补失败测试**

补断言，至少覆盖：

```ruby
assert_includes notes, "首次默认关闭"
assert_includes notes, "记住上一次"
assert_includes notes, "camwheel_guides_state.ini"
```

- [ ] **Step 2: 运行测试确认先失败**

Run: `ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb`

Expected: FAIL，提示文档尚未同步。

- [ ] **Step 3: 更新文档**

同步内容：

- README：首次默认关闭、后续记忆
- install.txt：状态文件与行为说明
- 手测清单：删除 INI 后首启验证、重启验证、宏切换验证

- [ ] **Step 4: 运行完整结构测试**

Run: `ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb`

Expected: PASS。

- [ ] **Step 5: 提交文档同步**

```bash
git add external/3dsmax_camwheel_viewport_export/README.md external/3dsmax_camwheel_viewport_export/install.txt docs/manual-test-checklist-3dsmax.md test/external/3dsmax_viewport_export_structure_test.rb
git commit -m "docs: add 3dsmax guide persistence notes"
```

