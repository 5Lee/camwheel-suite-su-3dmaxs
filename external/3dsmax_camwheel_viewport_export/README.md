# 构图辅助 for 3ds Max

`构图辅助` 是一个面向 3ds Max 视口工作的轻量插件，提供构图辅助线与原生流程的视口导出能力。

## 当前功能

- 视口辅助线
- 三分线 / 中心线 / 对角线
- 辅助线显示范围自动约束到安全框内
- 控制面板快速设置分辨率和比例
- 参数自动同步到渲染面板
- 相机批量截图
- 相机列表支持 `刷新列表` / `全选` / `反选`
- 视口右键菜单入口
- 工具栏图标入口
- 原生预览抓取导出 JPG
- 默认文件名为 `场景名-时间戳.jpg`
- 批量导出文件名为 `场景名-相机名.jpg`
- 导出时不包含辅助线

## 安装方式

推荐直接使用仓库中的打包文件：

- `dist/CamWheel_ViewportExport.mzp`
- `dist/3dsmax_camwheel_viewport_export.zip`

### 方式 1：拖拽安装

把 `CamWheel_ViewportExport.mzp` 直接拖进 3ds Max 视口。

### 方式 2：手动安装

把 `3dsmax_camwheel_viewport_export` 整个目录复制到 3ds Max 用户脚本目录。

## 使用方式

主要入口：

- `CamWheel / CamWheel_MainPanel`
- `CamWheel / CamWheel_ViewportExport`
- `CamWheel / CamWheel_ToggleGuides`

相机批量截图：

- 在控制面板右侧的 `相机批量截图` 区查看当前场景相机
- 左侧提供 `当前选中相机设置`
- 当前选中相机可单独设置 `比例预设 + 宽度 + 高度`
- 点击 `应用到当前相机` 后立即保存
- 点击 `刷新列表` 重新读取场景
- 使用 `全选` / `反选` 管理勾选状态
- 点击 `批量导出选中相机` 后选择一次目录
- 插件会逐个切换到勾选相机并导出 JPG
- 每个相机独立使用自己的比例和分辨率
- 批量导出文件名格式为 `场景名-相机名.jpg`
- 如果重名，会自动追加数字后缀

面板中的辅助线逻辑：

- 首次默认关闭辅助线
- 之后会记住上一次的 `显示辅助线 / 三分线 / 中心线 / 对角线` 状态
- 状态文件保存为 `camwheel_guides_state.ini`
- 勾选 `显示辅助线` 时才会在视口中显示辅助线
- `三分线 / 中心线 / 对角线` 各自独立控制是否绘制
- 不勾选 `显示辅助线` 时，下方辅助线选项不会生效

## 项目结构

- `CamWheel_ViewportExport.ms`：主入口、宏脚本、右键菜单、图标注册
- `panel.ms`：控制面板
- `guides.ms`：辅助线绘制
- `export.ms`：视口导出
- `mzp/`：MZP 安装脚本

## 测试

```bash
ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb
```

## 开源协议

`GPL-3.0`
