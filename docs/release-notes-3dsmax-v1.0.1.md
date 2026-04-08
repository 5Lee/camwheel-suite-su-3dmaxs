# 构图辅助 for 3ds Max

版本：`1.0.1`  
作者：`光影图像`  
开源协议：`GPL-3.0`

## 本次更新

本次为 `1.0.1` 补丁更新，重点是完善 3ds Max 相机批量截图工作流，并修复安装包中的导出脚本问题。

## 新增功能

- 控制面板新增 `相机批量截图` 区
- 支持读取场景相机并手动勾选
- 支持 `刷新列表`
- 支持 `全选`
- 支持 `反选`
- 支持 `批量导出选中相机`
- 批量导出文件名为 `场景名-相机名.jpg`
- 重名文件自动追加数字后缀

## 体验优化

- 辅助线首次默认关闭
- 后续会记住上一次的辅助线状态
- 状态保存为 `camwheel_guides_state.ini`
- 批量导出继续沿用 JPG 质量 `100`
- 导出时仍然不会把辅助线带进最终图片

## 修复

- 修复 3ds Max 2024 下相机排序比较函数导致的 `export.ms` 编译错误
- 重新生成可拖拽安装的 `MZP` 包和手动安装 `ZIP` 包

## 安装文件

- `dist/CamWheel_ViewportExport.mzp`
- `dist/3dsmax_camwheel_viewport_export.zip`

## 验证

```bash
ruby -Itest test/external/3dsmax_viewport_export_structure_test.rb
```

最近一次结果：

- `12 runs`
- `498 assertions`
- `0 failures`
- `0 errors`

