# 构图辅助 for 3ds Max

版本：`1.0.0`  
作者：`光影图像`  
开源协议：`GPL-3.0`

## 发布概述

这是 `构图辅助` 的 3ds Max 首个完整可用版本，核心目标是为视口工作流提供轻量、直接、可安装分发的构图辅助和原生导出能力。

本版本已经包含：

- 视口构图辅助线
- 原生预览抓取导出 JPG
- 控制面板
- 工具栏图标入口
- 视口右键菜单入口
- 可拖拽安装的 `MZP` 包

## 安装文件

推荐分发以下两个文件：

- `dist/CamWheel_ViewportExport.mzp`
- `dist/3dsmax_camwheel_viewport_export.zip`

说明：

- `mzp`：适合直接拖进 3ds Max 安装
- `zip`：适合手动复制脚本目录

## 核心功能

### 1. 构图辅助线

支持以下辅助线类型：

- 三分线
- 中心线
- 对角线

显示逻辑：

- 勾选 `显示辅助线` 时才显示辅助线
- `三分线 / 中心线 / 对角线` 各自独立控制
- 未勾选 `显示辅助线` 时，下方辅助线选项不会生效
- 辅助线绘制范围自动限制在安全框内

### 2. 视口导出

导出流程基于 3ds Max 原生预览抓取：

- 使用 `createPreview`
- 范围固定为 `0-0`
- `vpPreset:#userdefined`
- 输出格式为 `JPG`
- JPG 质量固定为 `100`

导出特性：

- 默认文件名：`场景名-时间戳.jpg`
- 未保存场景时使用 `camwheel-时间戳.jpg`
- 导出成功后有提示
- 导出时不会把辅助线一起输出

### 3. 控制面板

控制面板支持：

- 快速设置宽高
- 比例预设
- 快捷分辨率
- 自动同步到渲染面板
- 关于弹窗

当前常用比例预设：

- `1:1`
- `3:2`
- `3:4`
- `4:3`
- `4:5`
- `5:4`
- `9:16`
- `16:9`

### 4. 工具栏与菜单入口

支持以下入口：

- `CamWheel / CamWheel_MainPanel`
- `CamWheel / CamWheel_ViewportExport`
- `CamWheel / CamWheel_ToggleGuides`
- 视口右键菜单 `CamWheel`

工具栏图标逻辑：

- 插件启动时自动复制 PNG 图标到 `#userIcons`
- 宏脚本默认使用 `CamWheel/camwheel_panel`

## 本版本重点优化

相比开发过程中的中间版本，这一版已经完成以下收口：

- 修复启动 3ds Max 时自动弹出面板的问题
- 修复关于弹窗的 MAXScript 语法问题
- 工具栏入口改为图标导向
- 导出时隐藏辅助线，避免进入最终 JPG
- 辅助线范围按安全框显示
- 控制面板参数自动同步渲染面板
- 辅助线交互改为总开关 + 子项独立控制
- 补齐 `README`、安装说明、协议文件和测试

## 已知说明

- 当前辅助线是视口观察辅助，不替代 3ds Max 自带安全框
- 右键菜单在部分环境下如果没有立即出现，重启一次 3ds Max 后再测试
- 如果工具栏图标没有刷新，删除旧按钮后重新拖一次宏脚本即可

## 测试与验证

当前分支已通过结构级回归测试：

```bash
ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb
```

最近一次结果：

- `11 runs`
- `366 assertions`
- `0 failures`
- `0 errors`

## 仓库内相关位置

- 插件源码：`external/3dsmax_camwheel_viewport_export/`
- 打包产物：`dist/`
- 测试文件：`test/external/3dsmax_viewport_export_structure_test.rb`
- 安装与手测清单：`docs/manual-test-checklist-3dsmax.md`
