global CamWheel_GuideState
global CamWheel_GuideStateFilePath
global CamWheel_GuideOverlayCallback
global CamWheel_GetGuideStateFilePath
global CamWheel_GetGuideState
global CamWheel_SetGuideState
global CamWheel_SetGuideStateAndPersist
global CamWheel_ToggleGuides
global CamWheel_SetAllGuides
global CamWheel_RedrawGuides
global CamWheel_EnableGuideOverlay
global CamWheel_DisableGuideOverlay

fn CamWheel_DefaultGuideState =
(
  #(
    #guides_visible, false,
    #show_rule_of_thirds, true,
    #show_center_cross, false,
    #show_diagonals, false,
    #force_default_two_lights_on_export, true
  )
)

fn CamWheel_GetGuideStateFilePath =
(
  if CamWheel_GuideStateFilePath == undefined do
  (
    local scriptRoot = if CamWheel_ScriptRoot != undefined then CamWheel_ScriptRoot else (getFilenamePath (getSourceFileName()))
    CamWheel_GuideStateFilePath = pathConfig.appendPath scriptRoot "camwheel_guides_state.ini"
  )

  CamWheel_GuideStateFilePath
)

fn CamWheel_ParseGuideStateValue storedValue fallbackValue =
(
  if storedValue == undefined or storedValue == "" then return fallbackValue

  local normalizedValue = toLower (storedValue as string)
  if findItem #("true", "1", "yes", "on") normalizedValue > 0 then true
  else if findItem #("false", "0", "no", "off") normalizedValue > 0 then false
  else fallbackValue
)

fn CamWheel_LoadGuideState =
(
  local defaultState = CamWheel_DefaultGuideState()
  local stateFilePath = CamWheel_GetGuideStateFilePath()

  #(
    #guides_visible, (CamWheel_ParseGuideStateValue (getINISetting stateFilePath "guides" "guides_visible") defaultState[2]),
    #show_rule_of_thirds, (CamWheel_ParseGuideStateValue (getINISetting stateFilePath "guides" "show_rule_of_thirds") defaultState[4]),
    #show_center_cross, (CamWheel_ParseGuideStateValue (getINISetting stateFilePath "guides" "show_center_cross") defaultState[6]),
    #show_diagonals, (CamWheel_ParseGuideStateValue (getINISetting stateFilePath "guides" "show_diagonals") defaultState[8]),
    #force_default_two_lights_on_export, (CamWheel_ParseGuideStateValue (getINISetting stateFilePath "guides" "force_default_two_lights_on_export") defaultState[10])
  )
)

fn CamWheel_SaveGuideState =
(
  local stateFilePath = CamWheel_GetGuideStateFilePath()

  setINISetting stateFilePath "guides" "guides_visible" ((CamWheel_GetGuideState #guides_visible false) as string)
  setINISetting stateFilePath "guides" "show_rule_of_thirds" ((CamWheel_GetGuideState #show_rule_of_thirds true) as string)
  setINISetting stateFilePath "guides" "show_center_cross" ((CamWheel_GetGuideState #show_center_cross false) as string)
  setINISetting stateFilePath "guides" "show_diagonals" ((CamWheel_GetGuideState #show_diagonals false) as string)
  setINISetting stateFilePath "guides" "force_default_two_lights_on_export" ((CamWheel_GetGuideState #force_default_two_lights_on_export true) as string)
  true
)

if CamWheel_GuideState == undefined do
(
  CamWheel_GuideState = CamWheel_LoadGuideState()
)

fn CamWheel_GetGuideState key fallback =
(
  local indexValue = findItem CamWheel_GuideState key
  if indexValue > 0 then CamWheel_GuideState[indexValue + 1] else fallback
)

fn CamWheel_SetGuideState key value =
(
  local indexValue = findItem CamWheel_GuideState key
  if indexValue > 0 then CamWheel_GuideState[indexValue + 1] = value
)

fn CamWheel_SetGuideStateAndPersist key value =
(
  CamWheel_SetGuideState key value
  CamWheel_SaveGuideState()
  value
)

fn CamWheel_DrawGuideLine startPoint endPoint =
(
  gw.wPolyline #(startPoint, endPoint) false
)

fn CamWheel_GetSafeFrameRect widthValue heightValue =
(
  local outputWidth = renderWidth as float
  local outputHeight = renderHeight as float
  if outputWidth <= 0 or outputHeight <= 0 do return #(0.0, 0.0, widthValue, heightValue)

  local outputAspect = outputWidth / outputHeight
  local viewportAspect = widthValue / heightValue

  if viewportAspect > outputAspect then
  (
    local safeWidth = heightValue * outputAspect
    local safeLeft = (widthValue - safeWidth) / 2.0
    #(safeLeft, 0.0, safeWidth, heightValue)
  )
  else
  (
    local safeHeight = widthValue / outputAspect
    local safeTop = (heightValue - safeHeight) / 2.0
    #(0.0, safeTop, widthValue, safeHeight)
  )
)

fn CamWheel_DrawRuleOfThirds safeLeft safeTop safeWidth safeHeight =
(
  local xOne = safeLeft + (safeWidth / 3.0)
  local xTwo = safeLeft + ((safeWidth * 2.0) / 3.0)
  local yOne = safeTop + (safeHeight / 3.0)
  local yTwo = safeTop + ((safeHeight * 2.0) / 3.0)

  CamWheel_DrawGuideLine [xOne, safeTop, 0] [xOne, safeTop + safeHeight, 0]
  CamWheel_DrawGuideLine [xTwo, safeTop, 0] [xTwo, safeTop + safeHeight, 0]
  CamWheel_DrawGuideLine [safeLeft, yOne, 0] [safeLeft + safeWidth, yOne, 0]
  CamWheel_DrawGuideLine [safeLeft, yTwo, 0] [safeLeft + safeWidth, yTwo, 0]
)

fn CamWheel_DrawCenterCross safeLeft safeTop safeWidth safeHeight =
(
  local centerX = safeLeft + (safeWidth / 2.0)
  local centerY = safeTop + (safeHeight / 2.0)

  CamWheel_DrawGuideLine [centerX, safeTop, 0] [centerX, safeTop + safeHeight, 0]
  CamWheel_DrawGuideLine [safeLeft, centerY, 0] [safeLeft + safeWidth, centerY, 0]
)

fn CamWheel_DrawDiagonals safeLeft safeTop safeWidth safeHeight =
(
  CamWheel_DrawGuideLine [safeLeft, safeTop, 0] [safeLeft + safeWidth, safeTop + safeHeight, 0]
  CamWheel_DrawGuideLine [safeLeft + safeWidth, safeTop, 0] [safeLeft, safeTop + safeHeight, 0]
)

fn CamWheel_RedrawGuides =
(
  completeRedraw()
)

fn CamWheel_ToggleGuides =
(
  local visibleValue = not (CamWheel_GetGuideState #guides_visible true)
  CamWheel_SetGuideStateAndPersist #guides_visible visibleValue
  CamWheel_RedrawGuides()
  visibleValue
)

fn CamWheel_SetAllGuides enabledValue =
(
  CamWheel_SetGuideState #guides_visible enabledValue
  CamWheel_SetGuideState #show_rule_of_thirds enabledValue
  CamWheel_SetGuideState #show_center_cross enabledValue
  CamWheel_SetGuideState #show_diagonals enabledValue
  CamWheel_SaveGuideState()
  CamWheel_RedrawGuides()
)

fn CamWheel_DrawGuideOverlay =
(
  if not (CamWheel_GetGuideState #guides_visible true) then return false

  local widthValue = gw.getWinSizeX() as float
  local heightValue = gw.getWinSizeY() as float
  if widthValue <= 0 or heightValue <= 0 then return false
  local safeFrameRect = CamWheel_GetSafeFrameRect widthValue heightValue
  local safeLeft = safeFrameRect[1]
  local safeTop = safeFrameRect[2]
  local safeWidth = safeFrameRect[3]
  local safeHeight = safeFrameRect[4]

  gw.setTransform (matrix3 1)
  gw.setColor #line (color 255 210 64)

  if CamWheel_GetGuideState #show_rule_of_thirds true do
  (
    CamWheel_DrawRuleOfThirds safeLeft safeTop safeWidth safeHeight
  )

  if CamWheel_GetGuideState #show_center_cross false do
  (
    CamWheel_DrawCenterCross safeLeft safeTop safeWidth safeHeight
  )

  if CamWheel_GetGuideState #show_diagonals false do
  (
    CamWheel_DrawDiagonals safeLeft safeTop safeWidth safeHeight
  )

  gw.enlargeUpdateRect #whole
  gw.updateScreen()
  true
)

fn CamWheel_GuideOverlayCallback =
(
  CamWheel_DrawGuideOverlay()
)

fn CamWheel_EnableGuideOverlay =
(
  try(unRegisterRedrawViewsCallback CamWheel_GuideOverlayCallback)catch()
  registerRedrawViewsCallback CamWheel_GuideOverlayCallback
  CamWheel_RedrawGuides()
)

fn CamWheel_DisableGuideOverlay =
(
  try(unRegisterRedrawViewsCallback CamWheel_GuideOverlayCallback)catch()
  CamWheel_RedrawGuides()
)

CamWheel_EnableGuideOverlay()
