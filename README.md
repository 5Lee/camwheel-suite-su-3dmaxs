# CamWheel

`CamWheel` 是一个围绕构图辅助、视口导出和拼图排版整理的工具仓库，目前包含：

- SketchUp 插件：`CamWheel`
- 3ds Max 插件：`构图辅助`
- 独立 Web 工具：`CamWheel Canvas Tool`

## 项目结构

- [cam_wheel](/Users/liguangliang/nas/personal_folder/aicode/CamWheel/cam_wheel)：SketchUp 插件主代码
- [external/3dsmax_camwheel_viewport_export](/Users/liguangliang/nas/personal_folder/aicode/CamWheel/external/3dsmax_camwheel_viewport_export)：3ds Max 插件代码
- [dist](/Users/liguangliang/nas/personal_folder/aicode/CamWheel/dist)：当前打包产物
- [docs](/Users/liguangliang/nas/personal_folder/aicode/CamWheel/docs)：手测清单、设计稿、发布说明

## SketchUp 插件

SketchUp 版本当前包含以下主入口：

- `物体穿透`
- `视角对齐`
- `两点透视`
- `构图辅助`
- `拼图画布`
- `设置`

主要能力：

- 相机穿透与对齐
- 构图遮罩与辅助线
- 内置拼图画布入口
- 设置面板

### 安装

1. 将 `CamWheel.rb` 与整个 `cam_wheel/` 文件夹放入 SketchUp 插件目录。
2. 重新启动 SketchUp。
3. 在工具栏中启用 `CamWheel`。

常见插件目录：

- macOS: `~/Library/Application Support/SketchUp <version>/SketchUp/Plugins/`
- Windows: `%AppData%\\SketchUp\\SketchUp <version>\\SketchUp\\Plugins\\`

## 3ds Max 插件

3ds Max 版本插件中文名为 `构图辅助`，主要能力包括：

- 视口构图辅助线
- 原生预览抓取导出 JPG
- 控制面板
- 工具栏图标入口
- 视口右键菜单入口

推荐安装包：

- [dist/CamWheel_ViewportExport.mzp](/Users/liguangliang/nas/personal_folder/aicode/CamWheel/dist/CamWheel_ViewportExport.mzp)
- [dist/3dsmax_camwheel_viewport_export.zip](/Users/liguangliang/nas/personal_folder/aicode/CamWheel/dist/3dsmax_camwheel_viewport_export.zip)

更多说明可见：

- [external/3dsmax_camwheel_viewport_export/README.md](/Users/liguangliang/nas/personal_folder/aicode/CamWheel/external/3dsmax_camwheel_viewport_export/README.md)
- [docs/release-notes-3dsmax-v1.0.0.md](/Users/liguangliang/nas/personal_folder/aicode/CamWheel/docs/release-notes-3dsmax-v1.0.0.md)

## 独立 Web 工具

仓库同时提供可本地使用的拼图画布工具，适合不依赖 SketchUp 直接做图片排版、切片和导出。

当前相关文件：

- [cam_wheel/web_canvas_tool](/Users/liguangliang/nas/personal_folder/aicode/CamWheel/cam_wheel/web_canvas_tool)
- [dist/CamWheel-CanvasTool-Standalone.zip](/Users/liguangliang/nas/personal_folder/aicode/CamWheel/dist/CamWheel-CanvasTool-Standalone.zip)
- [dist/CamWheel-CanvasTool-Standalone-1.0.4.zip](/Users/liguangliang/nas/personal_folder/aicode/CamWheel/dist/CamWheel-CanvasTool-Standalone-1.0.4.zip)

主要能力：

- 无限画布拼图排版
- 多图导入与移动
- 吸附与参考线
- 框选、批量移动、按选区导出
- 图片切片
- 独立本地打开使用

## 开发与测试

- 目标兼容：SketchUp 内置 `Ruby 2.7` 与 `Ruby 3.2`
- 纯 Ruby 单元测试：

```bash
for test_file in test/cam_wheel/*_test.rb; do ruby -Itest "$test_file" || exit 1; done
```

- Ruby 语法检查：

```bash
ruby -c CamWheel.rb && find cam_wheel -name '*.rb' -print0 | xargs -0 -n1 ruby -c
```

3ds Max 插件结构测试：

```bash
ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb
```

## 分支说明

- `feature/camwheel-bootstrap`：当前 SketchUp 与 Web 工具主开发分支
- `codex/3dsmax-viewport-export`：3ds Max 插件独立开发分支

## 当前限制

- `视角对齐` 目前优先支持通过 `raytest` 命中的真实面，复杂包裹体的“语义外表面”还可以继续增强
- `物体穿透` 当前以首个命中对象的世界包围盒作为安全穿出依据，后续可以继续细化为更精准的几何穿出
