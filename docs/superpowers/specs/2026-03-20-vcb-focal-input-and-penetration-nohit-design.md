# CamWheel VCB 焦段输入与穿透无命中提示设计

## 目标
- 在 `构图辅助` 工具激活时使用 SketchUp VCB。
- 用户直接输入数字，例如 `35`、`50`、`85`，按全画幅 35mm 等效焦段处理。
- 工具将焦段换算为 FOV 并应用到当前透视相机，构图辅助不退出。
- `物体穿透` 在视线正前方中心无命中时，只提示，不移动相机。

## 方案
### 构图辅助 VCB
- `activate` 时设置 `Sketchup.vcb_label = "焦段(mm)"`，并根据当前相机 FOV 反算一个近似焦段显示到 `Sketchup.vcb_value`。
- 新增 `onUserText(text, view)`：解析纯数字输入，校验范围，换算成 FOV，应用到 `view.camera`。
- 若当前相机非透视，先尝试切回透视后再应用 FOV。
- 输入非法时仅提示，不改变当前视图。

### 换算规则
- 采用全画幅 36mm 画幅宽度作为基准。
- 公式：`fov = 2 * atan(36 / (2 * focal_length))`，输出角度制。
- 反向显示 VCB 时使用相反公式，将当前 `camera.fov` 近似换算为焦段。

### 物体穿透
- 保持当前中心射线命中逻辑。
- 若 `raytest` 无命中，则返回 `nil`，并由工具层提示 `CamWheel 前方中心没有物体`。
- 不做任何相机位移。

## 测试
- 为 `CompositionOverlayTool` 添加：
  - 焦段转 FOV 公式测试
  - `onUserText` 成功应用相机 FOV 测试
  - 非法输入不修改相机测试
- 为 `PenetrationTool` 添加：
  - 无命中时返回 `:no_hit`
  - 状态栏提示为“前方中心没有物体”
