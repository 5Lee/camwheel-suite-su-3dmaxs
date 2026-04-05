# CamWheel

`CamWheel` 当前包含两个独立方向的插件：

- SketchUp 插件：`CamWheel`，中文名“构图辅助仪”
- 3ds Max 插件：`构图辅助`

## SketchUp 插件

SketchUp 版本当前实现包含四个工具栏命令：

- `物体穿透`：沿当前视线穿过前方第一个遮挡物，并停在其包围范围之外
- `视角对齐`：点击可见面后对齐视角，并尝试切换到两点透视
- `构图辅助`：在视口中持续绘制构图遮罩与辅助线
- `设置`：打开 HtmlDialog 修改比例、线型、颜色、遮罩、穿透偏移等设置

### 安装

1. 将 `CamWheel.rb` 与整个 `cam_wheel/` 文件夹放入 SketchUp 插件目录。
2. 重新启动 SketchUp。
3. 在工具栏中启用 `CamWheel`。

常见插件目录：

- macOS: `~/Library/Application Support/SketchUp <version>/SketchUp/Plugins/`
- Windows: `%AppData%\\SketchUp\\SketchUp <version>\\SketchUp\\Plugins\\`

### 开发

- 目标兼容：SketchUp 内置 `Ruby 2.7` 与 `Ruby 3.2`
- 纯 Ruby 单元测试：

```bash
for test_file in test/cam_wheel/*_test.rb; do ruby -Itest "$test_file" || exit 1; done
```

- Ruby 语法检查：

```bash
ruby -c CamWheel.rb && find cam_wheel -name '*.rb' -print0 | xargs -0 -n1 ruby -c
```

### 当前限制

- `视角对齐` 目前优先支持通过 `raytest` 命中的真实面，复杂包裹体的“语义外表面”还可以继续增强
- `物体穿透` 当前以首个命中对象的世界包围盒作为安全穿出依据，后续可以继续细化为更精准的几何穿出

## 3ds Max 插件

3ds Max 版本位于 [external/3dsmax_camwheel_viewport_export](/Users/liguangliang/nas/personal_folder/aicode/CamWheel/.worktrees/3dsmax-viewport-export/external/3dsmax_camwheel_viewport_export)，核心能力包括：

- 视口构图辅助线：三分线、中心线、对角线，约束在安全框内显示
- 视口导出：走 3ds Max 原生预览抓取流程，默认导出 JPG
- 控制面板：快速设置比例、分辨率，并自动同步到渲染面板
- 工具栏图标与右键菜单入口

### 安装

推荐直接使用打包产物：

- `dist/CamWheel_ViewportExport.mzp`
- `dist/3dsmax_camwheel_viewport_export.zip`

`mzp` 适合拖入 3ds Max 直接安装，`zip` 适合手动复制脚本目录。

### 使用入口

- 工具栏：`CamWheel / CamWheel_MainPanel`
- 工具栏：`CamWheel / CamWheel_ViewportExport`
- 工具栏：`CamWheel / CamWheel_ToggleGuides`
- 右键菜单：视口右键中的 `CamWheel` 子菜单

### 开源协议

3ds Max 插件当前使用 `GPL-3.0`，协议文件位于：

- `external/3dsmax_camwheel_viewport_export/LICENSE`

### 验证

3ds Max 插件当前有结构级回归测试：

```bash
ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb
```
