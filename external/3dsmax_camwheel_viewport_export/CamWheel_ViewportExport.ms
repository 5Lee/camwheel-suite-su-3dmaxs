global CamWheel_ExportActiveViewport
global CamWheel_ShowPanel
global CamWheel_ToggleGuides
global CamWheel_RegisterLegacyContextMenu
global CamWheel_RegisterModernContextMenu
global CamWheel_InstallContextMenus
global CamWheel_ShowContextActions
global CamWheel_LegacyMenuInstalled
global CamWheel_ModernMenuInstalled
global CamWheel_ScriptRoot
global CamWheel_PluginName
global CamWheel_PluginVersion
global CamWheel_PluginAuthor
global CamWheel_PluginLicense
global CamWheel_ShowAbout
global CamWheel_EnsureToolbarIcons

if CamWheel_ScriptRoot == undefined do CamWheel_ScriptRoot = getFilenamePath (getSourceFileName())
if CamWheel_PluginName == undefined do CamWheel_PluginName = "构图辅助"
if CamWheel_PluginVersion == undefined do CamWheel_PluginVersion = "1.0.0"
if CamWheel_PluginAuthor == undefined do CamWheel_PluginAuthor = "光影图像"
if CamWheel_PluginLicense == undefined do CamWheel_PluginLicense = "GPL-3.0"

fn CamWheel_ShowAbout =
(
  local aboutText = CamWheel_PluginName + "\n" + "版本: " + CamWheel_PluginVersion + "\n" + "作者: " + CamWheel_PluginAuthor + "\n" + "开源协议: " + CamWheel_PluginLicense
  messageBox aboutText title:CamWheel_PluginName
)

fn CamWheel_CopyToolbarIcon sourceName targetName themeName =
(
  local userIconsRoot = try(getDir #userIcons)catch("")
  if userIconsRoot == undefined or userIconsRoot == "" then return false

  local sourcePath = pathConfig.appendPath (pathConfig.appendPath CamWheel_ScriptRoot "icons") sourceName
  if doesFileExist sourcePath == false then return false

  local themeRoot = pathConfig.appendPath userIconsRoot themeName
  local pluginRoot = pathConfig.appendPath themeRoot "CamWheel"
  makeDir pluginRoot all:true

  local targetPath = pathConfig.appendPath pluginRoot targetName
  copyFile sourcePath targetPath
)

fn CamWheel_EnsureToolbarIcons =
(
  local copiedAny = false

  for themeName in #("Light", "Dark") do
  (
    copiedAny = CamWheel_CopyToolbarIcon "camwheel_panel_24.png" "camwheel_panel_24.png" themeName or copiedAny
    copiedAny = CamWheel_CopyToolbarIcon "camwheel_panel_30.png" "camwheel_panel_30.png" themeName or copiedAny
  )

  copiedAny
)

fn CamWheel_LoadModules =
(
  fileIn (pathConfig.appendPath (getFilenamePath (getSourceFileName())) "export.ms")
  fileIn (pathConfig.appendPath (getFilenamePath (getSourceFileName())) "guides.ms")
  fileIn (pathConfig.appendPath (getFilenamePath (getSourceFileName())) "panel.ms")
)

CamWheel_LoadModules()
CamWheel_EnsureToolbarIcons()

if CamWheel_LegacyMenuInstalled == undefined do CamWheel_LegacyMenuInstalled = false
if CamWheel_ModernMenuInstalled == undefined do CamWheel_ModernMenuInstalled = false

macroScript CamWheel_ViewportExport
category:"CamWheel"
toolTip:"导出当前视口"
buttonText:"导出当前视口"
iconName:"CamWheel/camwheel_panel"
(
  on execute do CamWheel_ExportActiveViewport()
)

macroScript CamWheel_MainPanel
category:"CamWheel"
toolTip:"CamWheel 控制面板"
buttonText:"CamWheel 控制面板"
iconName:"CamWheel/camwheel_panel"
(
  on execute do CamWheel_ShowPanel()
)

macroScript CamWheel_ToggleGuides
category:"CamWheel"
toolTip:"显示/隐藏辅助线"
buttonText:"显示/隐藏辅助线"
iconName:"CamWheel/camwheel_panel"
(
  on execute do CamWheel_ToggleGuides()
)

macroScript CamWheel_OpenPanel
category:"CamWheel"
toolTip:"打开面板"
buttonText:"打开面板"
iconName:"CamWheel/camwheel_panel"
(
  on execute do CamWheel_ShowPanel()
)

fn CamWheel_AddLegacyContextActions targetMenu =
(
  if targetMenu == undefined then return false

  local camwheelMenu = menuMan.createMenu "CamWheel"
  camwheelMenu.addItem (menuMan.createActionItem "CamWheel_ViewportExport" "CamWheel") -1
  camwheelMenu.addItem (menuMan.createActionItem "CamWheel_ToggleGuides" "CamWheel") -1
  camwheelMenu.addItem (menuMan.createActionItem "CamWheel_OpenPanel" "CamWheel") -1
  targetMenu.addItem (menuMan.createSubMenuItem "CamWheel" camwheelMenu) -1
  true
)

fn CamWheel_RegisterLegacyContextMenu =
(
  if CamWheel_LegacyMenuInstalled then return true

  try
  (
    menuMan.registerMenuContext 0x43415745
    local viewportMenu = menuMan.getViewportRightClickMenu #nonePressed
    if CamWheel_AddLegacyContextActions viewportMenu then
    (
      CamWheel_LegacyMenuInstalled = true
      true
    )
    else
    (
      false
    )
  )
  catch
  (
    false
  )
)

fn CamWheel_RegisterModernContextMenu =
(
  if CamWheel_ModernMenuInstalled then return true

  try
  (
    local quadMenuManager = callbacks.notificationParam()
    if quadMenuManager == undefined then return false

    local viewportQuad = quadMenuManager.GetQuadMenuById "a8c true,6b0fd974-69ff-44ad-8c89-524b9ff01fe0"
    if viewportQuad == undefined then return false

    local targetQuad = viewportQuad.GetQuadByPos #BottomRight
    if targetQuad == undefined then return false

    local camwheelMenu = targetQuad.CreateSubMenu (genGUID()) "CamWheel"
    if camwheelMenu == undefined then return false

    camwheelMenu.CreateAction (genGUID()) 647394 "CamWheel_MainPanel`CamWheel"
    camwheelMenu.CreateAction (genGUID()) 647394 "CamWheel_ViewportExport`CamWheel"
    camwheelMenu.CreateAction (genGUID()) 647394 "CamWheel_ToggleGuides`CamWheel"
    camwheelMenu.CreateAction (genGUID()) 647394 "CamWheel_OpenPanel`CamWheel"

    CamWheel_ModernMenuInstalled = true
    true
  )
  catch
  (
    false
  )
)

fn CamWheel_RegisterModernContextMenuCallback =
(
  local modernCallbackId = #camwheelViewportExportQuadMenu
  try(callbacks.removeScripts id:modernCallbackId)catch()
  try(callbacks.addScript #cuiRegisterQuadMenus "CamWheel_RegisterModernContextMenu()" id:modernCallbackId)catch(false)
)

fn CamWheel_InstallContextMenus =
(
  CamWheel_RegisterModernContextMenuCallback()

  if CamWheel_RegisterLegacyContextMenu() then
  (
    format "CamWheel legacy viewport right-click menu installed.\n"
  )
  else
  (
    format "CamWheel legacy viewport right-click menu skipped.\n"
  )

  true
)

fn CamWheel_ShowContextActions =
(
  CamWheel_InstallContextMenus()
)

CamWheel_InstallContextMenus()
