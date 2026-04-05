fn CamWheel_RunMzpInstall =
(
  local camwheelScriptsRoot = pathConfig.appendPath (getDir #scripts) "3dsmax_camwheel_viewport_export"
  local camwheelEntryScript = pathConfig.appendPath camwheelScriptsRoot "CamWheel_ViewportExport.ms"

  if doesFileExist camwheelEntryScript then
  (
    fileIn camwheelEntryScript
    messageBox "构图辅助 已安装。\n作者：光影图像\n开源协议：GPL-3.0\n如需固定显示按钮，请到 Customize User Interface，把 CamWheel / CamWheel_MainPanel 拖到工具栏，并可指定 icons 目录中的图标。\n重启 3ds Max 后会自动加载。" title:"构图辅助"
  )
  else
  (
    messageBox "构图辅助 安装失败：未找到主脚本。" title:"构图辅助"
  )
)

CamWheel_RunMzpInstall()
