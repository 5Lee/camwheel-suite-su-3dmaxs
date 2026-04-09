global CamWheelPanelRollout
global CamWheel_ShowPanel
global CamWheel_SyncPanelState
global CamWheel_ReadRenderSettings
global CamWheel_ApplyRenderSettings
global CamWheel_PanelAspectRatio
global CamWheel_PanelSyncInProgress
global CamWheel_PanelCameraNodes
global CamWheel_PanelBatchStatusText
global CamWheel_PanelSelectedCameraIndex
global CamWheel_PanelEditingMode
global CamWheel_RoundPositive
global CamWheel_SyncRenderSettingsFromPanel
global CamWheel_PanelRefreshCameraList
global CamWheel_PanelSelectAllCameras
global CamWheel_PanelInvertCameraSelection
global CamWheel_PanelGetSelectedCameras
global CamWheel_PanelNodeIsUsable
global CamWheel_PanelGetCurrentEditingCamera
global CamWheel_PanelSyncEditingControls
global CamWheel_PanelPersistCurrentEditingSettings
global CamWheel_PanelSwitchToGlobalEditing
global CamWheel_PanelFormatCameraListItem
global CamWheel_PanelActivateCameraViewport

if CamWheel_PanelAspectRatio == undefined do CamWheel_PanelAspectRatio = 16.0 / 9.0
if CamWheel_PanelSyncInProgress == undefined do CamWheel_PanelSyncInProgress = false
if CamWheel_PanelCameraNodes == undefined do CamWheel_PanelCameraNodes = #()
if CamWheel_PanelBatchStatusText == undefined do CamWheel_PanelBatchStatusText = "最近批量导出：未执行"
if CamWheel_PanelSelectedCameraIndex == undefined do CamWheel_PanelSelectedCameraIndex = 0
if CamWheel_PanelEditingMode == undefined do CamWheel_PanelEditingMode = #global

fn CamWheel_GetAspectPresetItems =
(
  #("1:1", "3:2", "3:4", "4:3", "4:5", "5:4", "9:16", "16:9", "自定义")
)

fn CamWheel_GetAspectRatioFromLabel labelValue =
(
  case labelValue of
  (
    "1:1": 1.0
    "3:2": (3.0 / 2.0)
    "3:4": (3.0 / 4.0)
    "4:3": (4.0 / 3.0)
    "4:5": (4.0 / 5.0)
    "5:4": (5.0 / 4.0)
    "9:16": (9.0 / 16.0)
    "16:9": (16.0 / 9.0)
    default: CamWheel_PanelAspectRatio
  )
)

fn CamWheel_GetAspectPresetLabel widthValue heightValue =
(
  local ratioValue = if heightValue > 0 then (widthValue as float) / (heightValue as float) else (16.0 / 9.0)

  if abs(ratioValue - 1.0) < 0.01 then "1:1"
  else if abs(ratioValue - (3.0 / 2.0)) < 0.01 then "3:2"
  else if abs(ratioValue - (3.0 / 4.0)) < 0.01 then "3:4"
  else if abs(ratioValue - (4.0 / 3.0)) < 0.01 then "4:3"
  else if abs(ratioValue - (4.0 / 5.0)) < 0.01 then "4:5"
  else if abs(ratioValue - (5.0 / 4.0)) < 0.01 then "5:4"
  else if abs(ratioValue - (9.0 / 16.0)) < 0.01 then "9:16"
  else if abs(ratioValue - (16.0 / 9.0)) < 0.01 then "16:9"
  else "自定义"
)

fn CamWheel_RoundPositive value =
(
  amax 1 (((value as float) + 0.5) as integer)
)

fn CamWheel_ReadRenderSettings =
(
  #(renderWidth, renderHeight)
)

fn CamWheel_ApplyRenderSettings widthValue heightValue =
(
  renderWidth = amin 32768 (amax 1 widthValue)
  renderHeight = amin 32768 (amax 1 heightValue)
  rendLockImageAspectRatio = true
  rendImageAspectRatio = (renderWidth as float) / (renderHeight as float)
  if renderSceneDialog.isOpen() do renderSceneDialog.update()
  #(renderWidth, renderHeight)
)

fn CamWheel_UpdateAspectSelection widthValue heightValue =
(
  if CamWheelPanelRollout == undefined then return false

  local presetLabel = CamWheel_GetAspectPresetLabel widthValue heightValue
  local itemIndex = findItem CamWheelPanelRollout.aspectPresetDropdown.items presetLabel
  if itemIndex < 1 do itemIndex = findItem CamWheelPanelRollout.aspectPresetDropdown.items "自定义"
  if itemIndex > 0 do CamWheelPanelRollout.aspectPresetDropdown.selection = itemIndex
  CamWheel_PanelAspectRatio = if heightValue > 0 then (widthValue as float) / (heightValue as float) else CamWheel_PanelAspectRatio
  true
)

fn CamWheel_UpdateDimensionsFromWidth widthValue =
(
  local ratioValue = if CamWheel_PanelAspectRatio > 0 then CamWheel_PanelAspectRatio else (16.0 / 9.0)
  CamWheel_RoundPositive ((widthValue as float) / ratioValue)
)

fn CamWheel_UpdateDimensionsFromHeight heightValue =
(
  local ratioValue = if CamWheel_PanelAspectRatio > 0 then CamWheel_PanelAspectRatio else (16.0 / 9.0)
  CamWheel_RoundPositive ((heightValue as float) * ratioValue)
)

fn CamWheel_UpdateGuideToggleAvailability =
(
  if CamWheelPanelRollout == undefined then return false

  local guidesVisibleValue = CamWheelPanelRollout.guidesVisibleToggle.checked
  CamWheelPanelRollout.thirdsToggle.enabled = guidesVisibleValue
  CamWheelPanelRollout.centerToggle.enabled = guidesVisibleValue
  CamWheelPanelRollout.diagonalsToggle.enabled = guidesVisibleValue
  true
)

fn CamWheel_UpdateBatchStatusText textValue =
(
  CamWheel_PanelBatchStatusText = textValue
  if CamWheelPanelRollout != undefined do CamWheelPanelRollout.batchStatusLabel.text = textValue
  true
)

fn CamWheel_PanelFormatCameraListItem cameraNode =
(
  local cameraSettings = CamWheel_GetCameraExportSettings cameraNode
  cameraNode.name + "    " + (cameraSettings[1] as string) + "    " + (cameraSettings[2] as string) + "×" + (cameraSettings[3] as string)
)

fn CamWheel_PanelNodeIsUsable nodeValue =
(
  nodeValue != undefined and isValidNode nodeValue
)

fn CamWheel_PanelGetCurrentEditingCamera =
(
  if CamWheel_PanelSelectedCameraIndex < 1 then return undefined
  if CamWheel_PanelSelectedCameraIndex > CamWheel_PanelCameraNodes.count then return undefined

  local cameraNode = CamWheel_PanelCameraNodes[CamWheel_PanelSelectedCameraIndex]
  if CamWheel_PanelNodeIsUsable cameraNode then cameraNode else undefined
)

fn CamWheel_PanelPersistCurrentEditingSettings =
(
  if CamWheelPanelRollout == undefined then return false

  local presetLabel = CamWheelPanelRollout.aspectPresetDropdown.items[CamWheelPanelRollout.aspectPresetDropdown.selection]
  local widthValue = CamWheelPanelRollout.widthSpinner.value
  local heightValue = CamWheelPanelRollout.heightSpinner.value
  local cameraNode = CamWheel_PanelGetCurrentEditingCamera()

  if cameraNode == undefined then
  (
    CamWheel_SaveDefaultCameraExportSettings presetLabel widthValue heightValue
    CamWheel_UpdateBatchStatusText "已更新全局默认设置"
  )
  else
  (
    CamWheel_SaveCameraExportSettings cameraNode presetLabel widthValue heightValue
    CamWheel_UpdateBatchStatusText ("已更新相机设置：" + cameraNode.name)
  )

  true
)

fn CamWheel_PanelActivateCameraViewport cameraNode =
(
  if CamWheel_PanelNodeIsUsable cameraNode == false then return false

  viewport.setCamera cameraNode
  CamWheel_StabilizeViewportForExport()
  true
)

fn CamWheel_PanelSyncEditingControls =
(
  if CamWheelPanelRollout == undefined then return false

  local cameraNode = CamWheel_PanelGetCurrentEditingCamera()
  local editingSettings = undefined
  local renderSettings = undefined

  if cameraNode == undefined then
  (
    CamWheel_PanelEditingMode = #global
    editingSettings = CamWheel_GetDefaultCameraExportSettings()
    CamWheelPanelRollout.editingModeLabel.text = "当前编辑：全局默认"
    CamWheelPanelRollout.clearCameraSelectionButton.enabled = false
  )
  else
  (
    CamWheel_PanelEditingMode = #camera
    editingSettings = CamWheel_GetCameraExportSettings cameraNode
    CamWheelPanelRollout.editingModeLabel.text = "当前编辑：" + cameraNode.name
    CamWheelPanelRollout.clearCameraSelectionButton.enabled = true
    CamWheel_PanelActivateCameraViewport cameraNode
  )

  renderSettings = CamWheel_ApplyRenderSettings editingSettings[2] editingSettings[3]

  CamWheel_PanelSyncInProgress = true
  CamWheelPanelRollout.widthSpinner.value = renderSettings[1]
  CamWheelPanelRollout.heightSpinner.value = renderSettings[2]
  CamWheel_UpdateAspectSelection renderSettings[1] renderSettings[2]
  CamWheel_PanelSyncInProgress = false
  CamWheel_RedrawGuides()
  true
)

fn CamWheel_PanelRefreshCameraList =
(
  if CamWheelPanelRollout == undefined then return false

  local checkedCameraNames = #()
  local selectedCameraName = undefined
  local restoredSelectionIndex = 0

  for itemIndex = 0 to (CamWheelPanelRollout.cameraList.items.count - 1) do
  (
    local cachedCameraNode = if (itemIndex + 1) <= CamWheel_PanelCameraNodes.count then CamWheel_PanelCameraNodes[itemIndex + 1] else undefined
    if CamWheelPanelRollout.cameraList.GetItemChecked itemIndex and CamWheel_PanelNodeIsUsable cachedCameraNode do
      append checkedCameraNames cachedCameraNode.name
  )

  if CamWheel_PanelEditingMode == #camera do
  (
    local currentCamera = CamWheel_PanelGetCurrentEditingCamera()
    if CamWheel_PanelNodeIsUsable currentCamera do selectedCameraName = currentCamera.name
  )

  CamWheel_PanelCameraNodes = CamWheel_GetSceneCameras()

  CamWheel_PanelSyncInProgress = true
  CamWheelPanelRollout.cameraList.items.clear()

  for cameraNode in CamWheel_PanelCameraNodes do
  (
    local addedIndex = CamWheelPanelRollout.cameraList.items.add (CamWheel_PanelFormatCameraListItem cameraNode)
    if findItem checkedCameraNames cameraNode.name > 0 do CamWheelPanelRollout.cameraList.SetItemChecked addedIndex true
    if selectedCameraName != undefined and cameraNode.name == selectedCameraName do restoredSelectionIndex = addedIndex + 1
  )

  if restoredSelectionIndex > 0 then
  (
    CamWheel_PanelSelectedCameraIndex = restoredSelectionIndex
    CamWheelPanelRollout.cameraList.SelectedIndex = restoredSelectionIndex - 1
  )
  else
  (
    CamWheel_PanelSelectedCameraIndex = 0
    try(CamWheelPanelRollout.cameraList.ClearSelected())catch()
  )

  if CamWheel_PanelCameraNodes.count == 0 then
    CamWheel_UpdateBatchStatusText "当前场景未找到相机"
  else if CamWheel_PanelBatchStatusText == "当前场景未找到相机" then
    CamWheel_UpdateBatchStatusText "最近批量导出：未执行"

  CamWheel_PanelSyncInProgress = false
  CamWheel_PanelSyncEditingControls()
  true
)

fn CamWheel_PanelSelectAllCameras =
(
  if CamWheelPanelRollout == undefined then return false
  if CamWheelPanelRollout.cameraList.items.count < 1 then return true

  for cameraIndex = 0 to (CamWheelPanelRollout.cameraList.items.count - 1) do
  (
    CamWheelPanelRollout.cameraList.SetItemChecked cameraIndex true
  )

  true
)

fn CamWheel_PanelInvertCameraSelection =
(
  if CamWheelPanelRollout == undefined then return false
  if CamWheelPanelRollout.cameraList.items.count < 1 then return true

  for cameraIndex = 0 to (CamWheelPanelRollout.cameraList.items.count - 1) do
  (
    CamWheelPanelRollout.cameraList.SetItemChecked cameraIndex (not CamWheelPanelRollout.cameraList.GetItemChecked cameraIndex)
  )

  true
)

fn CamWheel_PanelGetSelectedCameras =
(
  local selectedCameraNodes = #()
  if CamWheelPanelRollout == undefined then return selectedCameraNodes
  if CamWheel_PanelCameraNodes.count < 1 then return selectedCameraNodes

  for cameraIndex = 0 to (CamWheel_PanelCameraNodes.count - 1) do
  (
    local cameraNode = CamWheel_PanelCameraNodes[cameraIndex + 1]
    if CamWheelPanelRollout.cameraList.GetItemChecked cameraIndex and CamWheel_PanelNodeIsUsable cameraNode do
    (
      append selectedCameraNodes cameraNode
    )
  )

  selectedCameraNodes
)

fn CamWheel_PanelSwitchToGlobalEditing =
(
  CamWheel_PanelEditingMode = #global
  CamWheel_PanelSelectedCameraIndex = 0

  if CamWheelPanelRollout != undefined do
  (
    CamWheel_PanelSyncInProgress = true
    try(CamWheelPanelRollout.cameraList.ClearSelected())catch()
    CamWheel_PanelSyncInProgress = false
  )

  CamWheel_PanelSyncEditingControls()
  true
)

fn CamWheel_ApplyQuickWidth quickWidth =
(
  if CamWheelPanelRollout == undefined then return false

  CamWheel_PanelSyncInProgress = true
  CamWheelPanelRollout.widthSpinner.value = quickWidth
  if CamWheelPanelRollout.lockAspectToggle.checked do
  (
    CamWheelPanelRollout.heightSpinner.value = CamWheel_UpdateDimensionsFromWidth quickWidth
  )
  CamWheel_PanelSyncInProgress = false
  CamWheel_UpdateAspectSelection CamWheelPanelRollout.widthSpinner.value CamWheelPanelRollout.heightSpinner.value
  CamWheel_SyncRenderSettingsFromPanel()
)

fn CamWheel_SyncRenderSettingsFromPanel =
(
  if CamWheelPanelRollout == undefined then return false

  local renderSettings = CamWheel_ApplyRenderSettings CamWheelPanelRollout.widthSpinner.value CamWheelPanelRollout.heightSpinner.value

  CamWheel_PanelSyncInProgress = true
  CamWheelPanelRollout.widthSpinner.value = renderSettings[1]
  CamWheelPanelRollout.heightSpinner.value = renderSettings[2]
  CamWheel_UpdateAspectSelection renderSettings[1] renderSettings[2]
  CamWheel_PanelSyncInProgress = false

  CamWheel_PanelPersistCurrentEditingSettings()
  CamWheel_PanelRefreshCameraList()
  CamWheel_RedrawGuides()
  true
)

fn CamWheel_SyncPanelState =
(
  if CamWheelPanelRollout == undefined then return false

  CamWheel_PanelSyncInProgress = true
  CamWheelPanelRollout.guidesVisibleToggle.checked = CamWheel_GetGuideState #guides_visible true
  CamWheelPanelRollout.lockAspectToggle.checked = true
  CamWheelPanelRollout.thirdsToggle.checked = CamWheel_GetGuideState #show_rule_of_thirds true
  CamWheelPanelRollout.centerToggle.checked = CamWheel_GetGuideState #show_center_cross false
  CamWheelPanelRollout.diagonalsToggle.checked = CamWheel_GetGuideState #show_diagonals false
  CamWheelPanelRollout.forceDefaultTwoLightsToggle.checked = CamWheel_GetGuideState #force_default_two_lights_on_export true
  CamWheelPanelRollout.batchStatusLabel.text = CamWheel_PanelBatchStatusText
  CamWheel_UpdateGuideToggleAvailability()
  CamWheel_PanelSyncInProgress = false

  CamWheel_PanelRefreshCameraList()
  true
)

rollout CamWheelPanelRollout "CamWheel 控制面板"
(
  groupBox renderSettingsGroup "导出与比例" pos:[10,8] width:220 height:162
  label editingModeLabel "当前编辑：全局默认" pos:[20,28] width:190 height:16
  dropdownlist aspectPresetDropdown "比例预设" pos:[20,50] items:(CamWheel_GetAspectPresetItems()) selection:8 width:180
  checkbox lockAspectToggle "锁定比例" pos:[20,80] checked:true
  spinner widthSpinner "宽度" pos:[20,108] range:[1,32768,1920] type:#integer fieldwidth:72
  spinner heightSpinner "高度" pos:[20,136] range:[1,32768,1080] type:#integer fieldwidth:72

  groupBox quickResolutionGroup "快捷分辨率" pos:[10,178] width:220 height:58
  button quick1024Button "1024" pos:[18,200] width:46
  button quick1920Button "1920" pos:[70,200] width:46
  button quick2048Button "2048" pos:[122,200] width:46
  button quick3840Button "3840" pos:[174,200] width:46

  button exportButton "导出当前视口" pos:[10,244] width:220 height:28

  groupBox guidesGroup "辅助线" pos:[10,280] width:220 height:76
  checkbox guidesVisibleToggle "显示辅助线" pos:[20,300] checked:true
  checkbox thirdsToggle "三分线" pos:[20,326] checked:true
  checkbox centerToggle "中心线" pos:[96,326] checked:false
  checkbox diagonalsToggle "对角线" pos:[172,326] checked:false

  button openPreviewDialogButton "打开预览面板" pos:[10,360] width:220 height:22
  button aboutButton "关于" pos:[10,388] width:220 height:22

  groupBox cameraBatchGroup "相机批量截图" pos:[242,8] width:308 height:374
  dotNetControl cameraList "System.Windows.Forms.CheckedListBox" pos:[252,30] width:288 height:238
  button refreshCameraListButton "刷新列表" pos:[252,276] width:64 height:24
  button selectAllCamerasButton "全选" pos:[324,276] width:64 height:24
  button invertCamerasButton "反选" pos:[396,276] width:64 height:24
  button clearCameraSelectionButton "切回全局" pos:[468,276] width:72 height:24 enabled:false
  button batchExportButton "批量导出选中相机" pos:[252,310] width:288 height:28
  checkbox forceDefaultTwoLightsToggle "强制两盏默认灯" pos:[252,342] checked:true
  label batchStatusLabel "" pos:[252,360] width:288 height:16

  on CamWheelPanelRollout open do
  (
    cameraList.CheckOnClick = true
    CamWheel_SyncPanelState()
  )

  on cameraList SelectedIndexChanged sender args do
  (
    CamWheel_PanelSelectedCameraIndex = cameraList.SelectedIndex + 1
    if not CamWheel_PanelSyncInProgress do CamWheel_PanelSyncEditingControls()
  )

  on aspectPresetDropdown selected itemIndex do
  (
    if not CamWheel_PanelSyncInProgress do
    (
      local presetLabel = aspectPresetDropdown.items[itemIndex]

      if presetLabel == "自定义" then
      (
        CamWheel_PanelAspectRatio = if heightSpinner.value > 0 then (widthSpinner.value as float) / (heightSpinner.value as float) else CamWheel_PanelAspectRatio
      )
      else
      (
        CamWheel_PanelAspectRatio = CamWheel_GetAspectRatioFromLabel presetLabel
        if lockAspectToggle.checked do
        (
          CamWheel_PanelSyncInProgress = true
          heightSpinner.value = CamWheel_UpdateDimensionsFromWidth widthSpinner.value
          CamWheel_PanelSyncInProgress = false
        )
      )

      CamWheel_SyncRenderSettingsFromPanel()
    )
  )

  on lockAspectToggle changed state do
  (
    if not CamWheel_PanelSyncInProgress and state do
    (
      local presetLabel = aspectPresetDropdown.items[aspectPresetDropdown.selection]
      if presetLabel != "自定义" then
        CamWheel_PanelAspectRatio = CamWheel_GetAspectRatioFromLabel presetLabel
      else
        CamWheel_PanelAspectRatio = if heightSpinner.value > 0 then (widthSpinner.value as float) / (heightSpinner.value as float) else CamWheel_PanelAspectRatio

      CamWheel_PanelSyncInProgress = true
      heightSpinner.value = CamWheel_UpdateDimensionsFromWidth widthSpinner.value
      CamWheel_PanelSyncInProgress = false
      CamWheel_SyncRenderSettingsFromPanel()
    )
  )

  on widthSpinner changed value do
  (
    if not CamWheel_PanelSyncInProgress do
    (
      if lockAspectToggle.checked do
      (
        CamWheel_PanelSyncInProgress = true
        heightSpinner.value = CamWheel_UpdateDimensionsFromWidth value
        CamWheel_PanelSyncInProgress = false
      )

      CamWheel_UpdateAspectSelection widthSpinner.value heightSpinner.value
      CamWheel_SyncRenderSettingsFromPanel()
    )
  )

  on heightSpinner changed value do
  (
    if not CamWheel_PanelSyncInProgress do
    (
      if lockAspectToggle.checked do
      (
        CamWheel_PanelSyncInProgress = true
        widthSpinner.value = CamWheel_UpdateDimensionsFromHeight value
        CamWheel_PanelSyncInProgress = false
      )

      CamWheel_UpdateAspectSelection widthSpinner.value heightSpinner.value
      CamWheel_SyncRenderSettingsFromPanel()
    )
  )

  on quick1024Button pressed do CamWheel_ApplyQuickWidth 1024
  on quick1920Button pressed do CamWheel_ApplyQuickWidth 1920
  on quick2048Button pressed do CamWheel_ApplyQuickWidth 2048
  on quick3840Button pressed do CamWheel_ApplyQuickWidth 3840

  on exportButton pressed do CamWheel_ExportActiveViewport()
  on openPreviewDialogButton pressed do CamWheel_OpenNativePreviewDialog()
  on refreshCameraListButton pressed do CamWheel_PanelRefreshCameraList()
  on selectAllCamerasButton pressed do CamWheel_PanelSelectAllCameras()
  on invertCamerasButton pressed do CamWheel_PanelInvertCameraSelection()
  on clearCameraSelectionButton pressed do CamWheel_PanelSwitchToGlobalEditing()

  on batchExportButton pressed do
  (
    try
    (
      local selectedCameras = CamWheel_PanelGetSelectedCameras()
      if selectedCameras.count == 0 then
      (
        messageBox "请先选择相机" title:"CamWheel"
        return false
      )

      local exportDirectory = CamWheel_RequestBatchExportDirectory()
      if exportDirectory == undefined then
      (
        CamWheel_UpdateBatchStatusText "最近批量导出：已取消"
        return false
      )

      local exportResult = CamWheel_ExportSelectedCameras selectedCameras exportDirectory
      CamWheel_UpdateBatchStatusText ("最近批量导出：成功 " + (exportResult[1] as string) + "，失败 " + (exportResult[2] as string))
      true
    )
    catch
    (
      format "CamWheel batch export panel failed -> error:%\n" (getCurrentException())
      messageBox ("批量导出失败：\n" + (getCurrentException() as string)) title:"CamWheel"
      false
    )
  )

  on aboutButton pressed do CamWheel_ShowAbout()

  on guidesVisibleToggle changed state do
  (
    CamWheel_SetGuideStateAndPersist #guides_visible state
    CamWheel_UpdateGuideToggleAvailability()
    CamWheel_RedrawGuides()
  )

  on thirdsToggle changed state do
  (
    CamWheel_SetGuideStateAndPersist #show_rule_of_thirds state
    CamWheel_RedrawGuides()
  )

  on centerToggle changed state do
  (
    CamWheel_SetGuideStateAndPersist #show_center_cross state
    CamWheel_RedrawGuides()
  )

  on diagonalsToggle changed state do
  (
    CamWheel_SetGuideStateAndPersist #show_diagonals state
    CamWheel_RedrawGuides()
  )

  on forceDefaultTwoLightsToggle changed state do
  (
    CamWheel_SetGuideStateAndPersist #force_default_two_lights_on_export state
  )
)

fn CamWheel_ShowPanel =
(
  try(destroyDialog CamWheelPanelRollout)catch()
  createDialog CamWheelPanelRollout 560 422
  CamWheel_SyncPanelState()
)
