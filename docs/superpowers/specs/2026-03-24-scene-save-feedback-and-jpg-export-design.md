# CamWheel 场景保存提示与 JPG 导出优化设计

## 目标
- 在构图辅助右键菜单触发原生“保存视图”后，只在场景实际创建成功时提示 `视角已保存`。
- 将构图图片导出链路从当前 PNG 路径切换到 JPG 路径，以贴近 SketchUp 原生 JPG 导出的速度表现。

## 方案

### 场景保存成功提示
- 保持现有原生动作桥接不变：
  - macOS 使用 `pageAdd:`
  - Windows 使用现有数值动作
- 触发原生命令前，读取当前 `Sketchup.active_model.pages.count`。
- 触发后使用 `UI.start_timer(0, false)` 延后检查一次 `pages.count`。
- 仅当场景数量增加时，弹出 `UI.messagebox("视角已保存")`。
- 若用户取消场景创建，或当前环境无法读取 `pages`，则不提示成功，避免误报。

### JPG 导出链路
- `ExportService` 默认文件名从 `.png` 改为 `.jpg`。
- 临时导出文件扩展名从 `.png` 改为 `.jpg`，让 `view.write_image(... compression: 0.9)` 真正走 JPEG 输出路径。
- 裁切后的最终保存文件同样按 `.jpg` 输出。
- 保留现有构图框计算、裁切、缩放和导出尺寸逻辑，不修改画面构成规则。

## 影响范围
- `cam_wheel/tools/composition_overlay_tool.rb`
  - 增加“原生场景保存成功后提示”的异步检查逻辑。
- `cam_wheel/services/export_service.rb`
  - 默认文件名改为 `.jpg`
  - 临时文件扩展名改为 `.jpg`
  - 保持现有裁切流程，仅切换图片格式链路
- `test/cam_wheel/composition_overlay_tool_test.rb`
  - 增加场景新增后提示测试
  - 增加未新增场景时不提示测试
- `test/cam_wheel/export_service_test.rb`
  - 更新默认文件名断言为 `.jpg`
- `test/cam_wheel/export_service_ui_resolution_test.rb`
  - 增加保存面板默认名与临时导出路径走 `.jpg` 的断言

## 风险与约束
- `pageAdd:` / 数值动作本身仍由 SketchUp 原生处理；插件只能通过“前后场景数对比”判断是否成功，不能拿到更细粒度结果。
- JPG 为有损格式，导出速度预计更快，但透明度与像素细节会不同于 PNG。
- 如果实际耗时主要来自后续 `ImageRep` 载入、裁切和重采样，而不是 `write_image` 本身，那么速度提升可能有限；这次改动优先验证最有可能的瓶颈。

## 测试
- 场景保存：
  - 点击“保存视图”后若 `pages.count` 增加，则弹出 `视角已保存`
  - 若 `pages.count` 不变，则不弹窗
- 导出：
  - 默认文件名格式改为 `模型名-时间戳.jpg`
  - 未保存模型回退为 `camwheel-时间戳.jpg`
  - 临时导出文件名使用 `.jpg`
