global CamWheelPanelRollout
global CamWheel_ShowPanel
global CamWheel_SyncPanelState
global CamWheel_ReadRenderSettings
global CamWheel_ApplyRenderSettings
global CamWheel_PanelAspectRatio
global CamWheel_PanelSyncInProgress
global CamWheel_RoundPositive
global CamWheel_SyncRenderSettingsFromPanel

if CamWheel_PanelAspectRatio == undefined do CamWheel_PanelAspectRatio = 16.0 / 9.0
if CamWheel_PanelSyncInProgress == undefined do CamWheel_PanelSyncInProgress = false

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
  CamWheel_RedrawGuides()
  true
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

fn CamWheel_SyncPanelState =
(
  if CamWheelPanelRollout == undefined then return false

  CamWheel_PanelSyncInProgress = true
  local renderSettings = CamWheel_ReadRenderSettings()

  CamWheelPanelRollout.widthSpinner.value = renderSettings[1]
  CamWheelPanelRollout.heightSpinner.value = renderSettings[2]
  CamWheel_UpdateAspectSelection renderSettings[1] renderSettings[2]
  CamWheelPanelRollout.guidesVisibleToggle.checked = CamWheel_GetGuideState #guides_visible true
  CamWheelPanelRollout.lockAspectToggle.checked = true
  CamWheelPanelRollout.thirdsToggle.checked = CamWheel_GetGuideState #show_rule_of_thirds true
  CamWheelPanelRollout.centerToggle.checked = CamWheel_GetGuideState #show_center_cross false
  CamWheelPanelRollout.diagonalsToggle.checked = CamWheel_GetGuideState #show_diagonals false
  CamWheel_UpdateGuideToggleAvailability()
  CamWheel_PanelSyncInProgress = false
  true
)

rollout CamWheelPanelRollout "CamWheel 控制面板"
(
  dropdownlist aspectPresetDropdown "比例预设" items:(CamWheel_GetAspectPresetItems()) selection:3 width:180
  checkbox lockAspectToggle "锁定比例" checked:true
  spinner widthSpinner "宽度" range:[1,32768,1920] type:#integer fieldwidth:72
  spinner heightSpinner "高度" range:[1,32768,1080] type:#integer fieldwidth:72
  groupBox quickResolutionGroup "快捷分辨率" width:180 height:56
  button quick1024Button "1024" width:38 across:4
  button quick1920Button "1920" width:38
  button quick2048Button "2048" width:38
  button quick3840Button "3840" width:38
  button exportButton "导出当前视口" width:180
  checkbox guidesVisibleToggle "显示辅助线" checked:true
  checkbox thirdsToggle "三分线" checked:true
  checkbox centerToggle "中心线" checked:false
  checkbox diagonalsToggle "对角线" checked:false
  button aboutButton "关于" width:180

  on CamWheelPanelRollout open do
  (
    CamWheel_SyncPanelState()
  )

  on aspectPresetDropdown selected itemIndex do
  (
    if not CamWheel_PanelSyncInProgress do
    (
      local presetLabel = aspectPresetDropdown.items[itemIndex]
      if presetLabel != "自定义" then
      (
        CamWheel_PanelAspectRatio = CamWheel_GetAspectRatioFromLabel presetLabel
        if lockAspectToggle.checked do
        (
          CamWheel_PanelSyncInProgress = true
          heightSpinner.value = CamWheel_UpdateDimensionsFromWidth widthSpinner.value
          CamWheel_PanelSyncInProgress = false
        )
        CamWheel_SyncRenderSettingsFromPanel()
      )
    )
  )

  on lockAspectToggle changed state do
  (
    if not CamWheel_PanelSyncInProgress and state do
    (
      local presetLabel = aspectPresetDropdown.items[aspectPresetDropdown.selection]
      if presetLabel != "自定义" do CamWheel_PanelAspectRatio = CamWheel_GetAspectRatioFromLabel presetLabel

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

  on aboutButton pressed do CamWheel_ShowAbout()

  on guidesVisibleToggle changed state do
  (
    CamWheel_SetGuideState #guides_visible state
    CamWheel_UpdateGuideToggleAvailability()
    CamWheel_RedrawGuides()
  )

  on thirdsToggle changed state do
  (
    CamWheel_SetGuideState #show_rule_of_thirds state
    CamWheel_RedrawGuides()
  )

  on centerToggle changed state do
  (
    CamWheel_SetGuideState #show_center_cross state
    CamWheel_RedrawGuides()
  )

  on diagonalsToggle changed state do
  (
    CamWheel_SetGuideState #show_diagonals state
    CamWheel_RedrawGuides()
  )
)

fn CamWheel_ShowPanel =
(
  try(destroyDialog CamWheelPanelRollout)catch()
  createDialog CamWheelPanelRollout 220 390
  CamWheel_SyncPanelState()
)
