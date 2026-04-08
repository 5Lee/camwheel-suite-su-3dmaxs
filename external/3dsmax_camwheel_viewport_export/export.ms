global CamWheel_DefaultExportFilename
global CamWheel_RequestExportPath
global CamWheel_RequestBatchExportDirectory
global CamWheel_RunNativePreviewExport
global CamWheel_ShowExportSuccess
global CamWheel_ShowExportCanceled
global CamWheel_ShowExportFailure
global CamWheel_GetSceneCameras
global CamWheel_SanitizeExportNamePart
global CamWheel_BuildBatchExportFilename
global CamWheel_ResolveUniqueExportPath
global CamWheel_CompareCameraNodesByName
global CamWheel_GetDefaultCameraExportSettings
global CamWheel_GetCameraExportSettings
global CamWheel_SaveCameraExportSettings
global CamWheel_ApplyCameraExportSettings
global CamWheel_ExportViewportForCamera
global CamWheel_ExportSelectedCameras
global CamWheel_ExportActiveViewport
global CamWheel_GetGuideState
global CamWheel_SetGuideState
global CamWheel_RedrawGuides

fn CamWheel_FormatTimestamp =
(
  local timeParts = getLocalTime()
  local yearValue = timeParts[1] as string
  local monthValue = formattedPrint timeParts[2] format:"02d"
  local dayValue = formattedPrint timeParts[3] format:"02d"
  local hourValue = formattedPrint timeParts[5] format:"02d"
  local minuteValue = formattedPrint timeParts[6] format:"02d"
  local secondValue = formattedPrint timeParts[7] format:"02d"
  yearValue + monthValue + dayValue + "-" + hourValue + minuteValue + secondValue
)

fn CamWheel_NormalizeExportPath exportPath =
(
  if exportPath == undefined then return undefined
  if matchPattern (toLower exportPath) pattern:"*.jpg" then exportPath else (exportPath + ".jpg")
)

fn CamWheel_DefaultExportFilename =
(
  local sceneStem = if maxFileName != undefined and maxFileName != "" then getFilenameFile maxFileName else "camwheel"
  sceneStem + "-" + (CamWheel_FormatTimestamp()) + ".jpg"
)

fn CamWheel_RequestExportPath suggestedName =
(
  getSaveFileName \
    caption:"导出当前视口" \
    filename:suggestedName \
    types:"JPEG (*.jpg)|*.jpg|"
)

fn CamWheel_RequestBatchExportDirectory =
(
  getSavePath caption:"选择批量导出文件夹"
)

fn CamWheel_GetCameraSettingsSectionName cameraNode =
(
  "camera." + (CamWheel_SanitizeExportNamePart (if cameraNode != undefined then cameraNode.name else "camera"))
)

fn CamWheel_CompareCameraNodesByName leftNode rightNode =
(
  stricmp leftNode.name rightNode.name < 0
)

fn CamWheel_GetSceneCameras =
(
  local cameraNodes = #()

  for cameraNode in cameras do
  (
    if viewport.CanSetToViewport cameraNode do append cameraNodes cameraNode
  )

  qsort cameraNodes CamWheel_CompareCameraNodesByName
  cameraNodes
)

fn CamWheel_SanitizeExportNamePart value =
(
  local sanitizedValue = if value == undefined then "" else (value as string)

  for invalidCharacter in #("\\", "/", ":", "*", "?", "\"", "<", ">", "|") do
  (
    sanitizedValue = substituteString sanitizedValue invalidCharacter "-"
  )

  if sanitizedValue == "" then "camwheel" else sanitizedValue
)

fn CamWheel_BuildBatchExportFilename cameraNode =
(
  local sceneName = CamWheel_SanitizeExportNamePart (if maxFileName != undefined and maxFileName != "" then getFilenameFile maxFileName else "camwheel")
  local cameraName = CamWheel_SanitizeExportNamePart (if cameraNode != undefined then cameraNode.name else "camera")
  sceneName + "-" + cameraName + ".jpg"
)

fn CamWheel_ResolveUniqueExportPath directory filename =
(
  local normalizedFilename = CamWheel_NormalizeExportPath filename
  local nameStem = getFilenameFile normalizedFilename
  local extension = getFilenameType normalizedFilename
  local resolvedPath = pathConfig.appendPath directory normalizedFilename
  local duplicateIndex = 2

  while doesFileExist resolvedPath do
  (
    resolvedPath = pathConfig.appendPath directory (nameStem + "-" + (duplicateIndex as string) + extension)
    duplicateIndex += 1
  )

  resolvedPath
)

fn CamWheel_GetDefaultCameraExportSettings =
(
  local defaultPresetLabel = if renderHeight > 0 then ((renderWidth as string) + ":" + (renderHeight as string)) else "自定义"
  #(defaultPresetLabel, renderWidth, renderHeight)
)

fn CamWheel_GetCameraExportSettings cameraNode =
(
  local defaultSettings = CamWheel_GetDefaultCameraExportSettings()
  local stateFilePath = CamWheel_GetGuideStateFilePath()
  local sectionName = CamWheel_GetCameraSettingsSectionName cameraNode

  local presetLabel = getINISetting stateFilePath sectionName "aspect_preset"
  local widthValue = getINISetting stateFilePath sectionName "width"
  local heightValue = getINISetting stateFilePath sectionName "height"

  if presetLabel == undefined or presetLabel == "" do presetLabel = defaultSettings[1]
  if widthValue == undefined or widthValue == "" then widthValue = defaultSettings[2] else widthValue = amax 1 (widthValue as integer)
  if heightValue == undefined or heightValue == "" then heightValue = defaultSettings[3] else heightValue = amax 1 (heightValue as integer)

  #(presetLabel, widthValue, heightValue)
)

fn CamWheel_SaveCameraExportSettings cameraNode presetLabel widthValue heightValue =
(
  if cameraNode == undefined then return false

  local stateFilePath = CamWheel_GetGuideStateFilePath()
  local sectionName = CamWheel_GetCameraSettingsSectionName cameraNode

  setINISetting stateFilePath sectionName "aspect_preset" (presetLabel as string)
  setINISetting stateFilePath sectionName "width" ((amax 1 widthValue) as string)
  setINISetting stateFilePath sectionName "height" ((amax 1 heightValue) as string)
  true
)

fn CamWheel_ApplyCameraExportSettings cameraNode =
(
  local cameraSettings = CamWheel_GetCameraExportSettings cameraNode
  renderWidth = amin 32768 (amax 1 cameraSettings[2])
  renderHeight = amin 32768 (amax 1 cameraSettings[3])
  rendLockImageAspectRatio = true
  rendImageAspectRatio = (renderWidth as float) / (renderHeight as float)
  if renderSceneDialog.isOpen() do renderSceneDialog.update()
  cameraSettings
)

fn CamWheel_RunNativePreviewExport exportPath =
(
  local normalizedPath = CamWheel_NormalizeExportPath exportPath
  if normalizedPath == undefined then return false

  jpeg.ijpegio.setQuality 100

  -- Native preview wrapper contract:
  -- current active viewport only
  -- tools -> preview grab viewport -> create preview animation
  -- custom frame range 0-0
  -- visual style Standard
  -- output .jpg
  format "CamWheel native preview export -> file:% viewport:% frames:% style:%\n" \
    normalizedPath \
    "current active viewport" \
    "0-0" \
    "Standard"

  -- 3ds Max 2024.1+ exposes vpPreset / autoPlay in createPreview().
  -- If these keywords are unavailable, fall back to the older parameter set.
  try
  (
    createPreview \
      filename:normalizedPath \
      outputAVI:false \
      start:0 \
      end:0 \
      skip:1 \
      dspSafeFrame:false \
      autoPlay:false \
      vpPreset:#userdefined
    true
  )
  catch
  (
    createPreview \
      filename:normalizedPath \
      outputAVI:false \
      start:0 \
      end:0 \
      skip:1 \
      dspSafeFrame:false \
      rndLevel:#smoothhighlights
    true
  )
)

fn CamWheel_ShowExportSuccess exportPath =
(
  messageBox "图片已导出" title:"CamWheel"
)

fn CamWheel_ShowExportCanceled =
(
  format "CamWheel export canceled by user\n"
  false
)

fn CamWheel_ShowExportFailure errorMessage =
(
  messageBox ("导出失败：\n" + errorMessage as string) title:"CamWheel"
  false
)

fn CamWheel_ExportViewportForCamera cameraNode exportPath =
(
  if cameraNode == undefined then throw "未提供可导出的相机。"

  local normalizedPath = CamWheel_NormalizeExportPath exportPath
  local originalGuideVisibility = CamWheel_GetGuideState #guides_visible true

  try
  (
    CamWheel_ApplyCameraExportSettings cameraNode
    viewport.setCamera cameraNode
    CamWheel_SetGuideState #guides_visible false
    CamWheel_RedrawGuides()
    local exportSucceeded = CamWheel_RunNativePreviewExport normalizedPath
    CamWheel_SetGuideState #guides_visible originalGuideVisibility
    CamWheel_RedrawGuides()
    exportSucceeded
  )
  catch
  (
    CamWheel_SetGuideState #guides_visible originalGuideVisibility
    CamWheel_RedrawGuides()
    throw()
  )
)

fn CamWheel_JoinNameList values =
(
  local joinedValue = ""

  for valueIndex = 1 to values.count do
  (
    if valueIndex > 1 do joinedValue += ", "
    joinedValue += (values[valueIndex] as string)
  )

  joinedValue
)

fn CamWheel_ExportSelectedCameras cameraNodes exportDirectory =
(
  local successCount = 0
  local failedCameraNames = #()
  local resultDirectory = exportDirectory

  if cameraNodes == undefined or cameraNodes.count == 0 do return #(0, 0, resultDirectory, failedCameraNames)
  if resultDirectory == undefined or resultDirectory == "" do return #(0, cameraNodes.count, resultDirectory, failedCameraNames)

  for cameraNode in cameraNodes do
  (
    local exportFilename = CamWheel_BuildBatchExportFilename cameraNode
    local exportPath = CamWheel_ResolveUniqueExportPath resultDirectory exportFilename

    try
    (
      if CamWheel_ExportViewportForCamera cameraNode exportPath then
      (
        successCount += 1
      )
      else
      (
        append failedCameraNames cameraNode.name
      )
    )
    catch
    (
      append failedCameraNames cameraNode.name
    )
  )

  local failureCount = failedCameraNames.count
  local summaryText = "批量导出完成。\n成功: " + (successCount as string) + "\n失败: " + (failureCount as string)

  if resultDirectory != undefined and resultDirectory != "" do
  (
    summaryText += "\n目录:\n" + resultDirectory
  )

  if failureCount > 0 do
  (
    summaryText += "\n失败相机:\n" + (CamWheel_JoinNameList failedCameraNames)
  )

  messageBox summaryText title:"CamWheel"
  #(successCount, failureCount, resultDirectory, failedCameraNames)
)

fn CamWheel_ExportActiveViewport =
(
  local exportPath = CamWheel_RequestExportPath (CamWheel_DefaultExportFilename())
  if exportPath == undefined then return CamWheel_ShowExportCanceled()

  local normalizedPath = CamWheel_NormalizeExportPath exportPath
  local originalGuideVisibility = CamWheel_GetGuideState #guides_visible true

  try
  (
    CamWheel_SetGuideState #guides_visible false
    CamWheel_RedrawGuides()

    if CamWheel_RunNativePreviewExport normalizedPath then
    (
      CamWheel_SetGuideState #guides_visible originalGuideVisibility
      CamWheel_RedrawGuides()
      CamWheel_ShowExportSuccess normalizedPath
      true
    )
    else
    (
      CamWheel_SetGuideState #guides_visible originalGuideVisibility
      CamWheel_RedrawGuides()
      CamWheel_ShowExportFailure "原生预览抓取未返回成功状态。"
    )
  )
  catch
  (
    CamWheel_SetGuideState #guides_visible originalGuideVisibility
    CamWheel_RedrawGuides()
    CamWheel_ShowExportFailure (getCurrentException())
  )
)
