# 3ds Max 辅助线默认关闭与状态持久化设计

## 背景

当前 3ds Max 插件在首次加载时会直接启用辅助线，并使用内存中的全局状态保存：

- `guides_visible = true`
- `show_rule_of_thirds = true`
- `show_center_cross = false`
- `show_diagonals = false`

这种行为的问题是：

- 第一次加载就显示辅助线，不符合新的默认体验要求
- 用户修改开关状态后，重启 3ds Max 会丢失

## 目标

- 第一次启动插件时，默认不显示辅助线
- 第一次默认值为：
  - `显示辅助线 = 关闭`
  - `三分线 = 开启`
  - `中心线 = 关闭`
  - `对角线 = 关闭`
- 之后记住用户上一次的四个开关状态
- 面板切换与宏命令切换都要同步保存

## 非目标

- 不新增新的 UI 控件
- 不改变辅助线绘制样式
- 不改变导出时隐藏辅助线的逻辑
- 不影响 SU 插件

## 方案对比

### 方案 1：本地配置文件持久化

- 在插件脚本目录写一个很小的状态文件
- 启动时读取，用户改动时回写
- 第一次无文件时使用默认关闭值

优点：

- 满足“第一次默认关闭，之后记住状态”
- 跨 3ds Max 重启有效
- 实现简单，依赖少

缺点：

- 需要维护一个小配置文件

### 方案 2：仅内存持久化

- 仍然只使用 `CamWheel_GuideState`
- 仅在当前 3ds Max 会话中保留状态

优点：

- 代码改动小

缺点：

- 重启 3ds Max 后丢失
- 不满足需求

## 采用方案

采用 **方案 1：本地配置文件持久化**。

## 交互与行为设计

### 首次启动

当插件启动且配置文件不存在时：

- 创建默认状态：
  - `guides_visible = false`
  - `show_rule_of_thirds = true`
  - `show_center_cross = false`
  - `show_diagonals = false`
- 加载辅助线回调，但由于 `guides_visible = false`，视口默认不显示辅助线
- 打开控制面板时，复选框显示上述默认值

### 后续启动

当配置文件存在时：

- 启动时读取 4 个状态值
- 用读取结果初始化 `CamWheel_GuideState`
- 打开控制面板时直接显示上次状态

### 状态保存时机

以下操作后立即保存：

- 点击面板中的 `显示辅助线`
- 点击面板中的 `三分线`
- 点击面板中的 `中心线`
- 点击面板中的 `对角线`
- 使用宏命令或右键菜单触发 `显示/隐藏辅助线`

## 技术设计

### 涉及文件

- `external/3dsmax_camwheel_viewport_export/guides.ms`
- `external/3dsmax_camwheel_viewport_export/panel.ms`
- `test/external/3dsmax_viewport_export_structure_test.rb`
- 如有必要，补充说明文档

### 持久化文件

建议放在插件脚本目录下，例如：

- `3dsmax_camwheel_viewport_export/camwheel_guides_state.ini`

文件内容保持极简，保存 4 个布尔值即可。

### 建议新增函数

在 `guides.ms` 中新增或补充：

- `CamWheel_GuideStateFilePath`
- `CamWheel_DefaultGuideState()`
- `CamWheel_LoadGuideState()`
- `CamWheel_SaveGuideState()`
- `CamWheel_SetGuideStateAndPersist key value`

### 数据流

1. 插件加载 `guides.ms`
2. 初始化状态文件路径
3. 尝试从磁盘读取状态
4. 若读取失败或文件不存在，则使用默认状态
5. 用户通过面板或宏命令修改状态
6. 每次修改后立即写回磁盘

## 错误处理

- 配置文件不存在：使用默认状态
- 配置文件损坏：忽略损坏内容并回退默认状态
- 写入失败：不阻断插件使用，但保留当前内存状态

## 验证计划

1. 删除状态文件后启动插件，确认辅助线默认关闭
2. 首次打开面板，确认三分线开、中心线关、对角线关
3. 修改四个开关，关闭 3ds Max 后重启，确认状态被记住
4. 使用 `CamWheel_ToggleGuides` 宏命令切换后重启，确认状态被记住
5. 导出图片时仍然不会把辅助线导出进去
