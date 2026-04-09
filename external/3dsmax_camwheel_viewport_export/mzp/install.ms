fn CamWheel_ShowMzpInstallMessage messageText titleText:"构图辅助" =
(
  format "CamWheel MZP install -> %\n" messageText
  try(windows.processPostedMessages())catch()
  try
  (
    local formsMessageBox = dotNetClass "System.Windows.Forms.MessageBox"
    formsMessageBox.Show messageText titleText
  )
  catch
  (
    messageBox messageText title:titleText
  )
)

fn CamWheel_RunMzpInstall =
(
  local camwheelScriptsRoot = pathConfig.appendPath (getDir #scripts) "3dsmax_camwheel_viewport_export"
  local camwheelEntryScript = pathConfig.appendPath camwheelScriptsRoot "CamWheel_ViewportExport.ms"

  if doesFileExist camwheelEntryScript == false then
  (
    CamWheel_ShowMzpInstallMessage ("构图辅助 安装失败：未找到主脚本。\n路径：\n" + camwheelEntryScript)
    return false
  )

  try
  (
    fileIn camwheelEntryScript

    local loadedSuccessfully = true
    local panelOpened = false
    if CamWheel_EnsureLoaded != undefined do
      loadedSuccessfully = CamWheel_EnsureLoaded()

    if loadedSuccessfully then
    (
      if CamWheel_ShowPanel != undefined do
      (
        try(panelOpened = CamWheel_ShowPanel())catch(panelOpened = false)
      )
      format "CamWheel MZP install success -> panelOpened:%\n" panelOpened
      CamWheel_ShowMzpInstallMessage "构图辅助 已安装。\n作者：光影图像\n开源协议：GPL-3.0\n如需固定显示按钮，请到 Customize User Interface，把 CamWheel / CamWheel_MainPanel 拖到工具栏，并可指定 icons 目录中的图标。\n重启 3ds Max 后会自动加载。"
      true
    )
    else
    (
      CamWheel_ShowMzpInstallMessage "构图辅助 安装失败：主脚本已复制，但加载未完成。\n请打开 MAXScript Listener 查看详细日志。"
      false
    )
  )
  catch
  (
    local errorMessage = getCurrentException() as string
    CamWheel_ShowMzpInstallMessage ("构图辅助 安装失败：\n" + errorMessage + "\n\n请打开 MAXScript Listener 查看详细日志。")
    false
  )
)

CamWheel_RunMzpInstall()
