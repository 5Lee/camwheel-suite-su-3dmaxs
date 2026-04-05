global CamWheel_DefaultExportFilename
global CamWheel_RequestExportPath
global CamWheel_RunNativePreviewExport
global CamWheel_ShowExportSuccess
global CamWheel_ShowExportCanceled
global CamWheel_ShowExportFailure
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
