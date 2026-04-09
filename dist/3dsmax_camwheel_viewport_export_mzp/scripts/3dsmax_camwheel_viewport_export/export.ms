global CamWheel_DefaultExportFilename
global CamWheel_RequestExportPath
global CamWheel_RequestBatchExportDirectory
global CamWheel_RunSingleFramePreviewExport
global CamWheel_RunPreviewWithUserDefinedPreset
global CamWheel_RunPreviewWithLegacyDefaults
global CamWheel_RunNativePreviewExport
global CamWheel_ShowExportSuccess
global CamWheel_ShowExportCanceled
global CamWheel_ShowExportFailure
global CamWheel_GetSceneCameras
global CamWheel_SanitizeExportNamePart
global CamWheel_BuildBatchExportFilename
global CamWheel_ResolveUniqueExportPath
global CamWheel_CompareCameraNodesByName
global CamWheel_GetGlobalExportSettingsSectionName
global CamWheel_GetDefaultCameraExportSettings
global CamWheel_SaveDefaultCameraExportSettings
global CamWheel_GetCameraExportSettings
global CamWheel_SaveCameraExportSettings
global CamWheel_ApplyCameraExportSettings
global CamWheel_ExportViewportForCamera
global CamWheel_ExportSelectedCameras
global CamWheel_ExportActiveViewport
global CamWheel_GetGuideStateFilePath
global CamWheel_GetGuideState
global CamWheel_SetGuideState
global CamWheel_RedrawGuides
global CamWheel_GetAspectPresetLabelForSize
global CamWheel_DidExportWriteFile
global CamWheel_StabilizeViewportForExport
global CamWheel_CaptureViewportLightingState
global CamWheel_CreateForcedViewportLightingState
global CamWheel_ApplyViewportLightingState
global CamWheel_CanUseUserDefinedPreviewPreset
global CamWheel_GetDotNetGlobalInterface
global CamWheel_GetPreviewCoreInterface
global CamWheel_GetDotNetPreviewParams
global CamWheel_LogSdkCreatePreviewOverloads
global CamWheel_ApplyLegacySingleFramePreviewSettings
global CamWheel_RunPreviewWithLegacyDialogParams
global CamWheel_RunPreviewWithLegacyExplicitRange
global CamWheel_RunPreviewWithSdkIntPtr
global CamWheel_RunPreviewWithSdkParams
global CamWheel_UseCurrentPreviewSettingsOnce
global CamWheel_RunPreviewWithCurrentSettings
global CamWheel_OpenNativePreviewDialog
global CamWheel_LogCurrentPreviewSettings
global CamWheel_ApplyLegacyPreviewSettingsForFrame
global CamWheel_GetCoreAnimRangeSnapshot
global CamWheel_ApplyCoreSingleFramePreviewRange

if CamWheel_UseCurrentPreviewSettingsOnce == undefined do CamWheel_UseCurrentPreviewSettingsOnce = false

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

fn CamWheel_GetAspectPresetLabelForSize widthValue heightValue =
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

fn CamWheel_GetGlobalExportSettingsSectionName =
(
  "global_export"
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

fn CamWheel_DidExportWriteFile exportPath =
(
  local normalizedPath = CamWheel_NormalizeExportPath exportPath
  normalizedPath != undefined and doesFileExist normalizedPath
)

fn CamWheel_StabilizeViewportForExport =
(
  completeRedraw()
  try(windows.processPostedMessages())catch()
  sleep 0.1
  try(windows.processPostedMessages())catch()
  completeRedraw()
  true
)

fn CamWheel_CaptureViewportLightingState =
(
  local viewportSetting = undefined

  try(viewportSetting = NitrousGraphicsManager.GetActiveViewportSetting())catch()
  if viewportSetting == undefined then return undefined

  #(
    #(#VisualStyleMode, viewportSetting.VisualStyleMode),
    #(#LightOption, viewportSetting.LightOption),
    #(#DefaultLightMode, viewportSetting.DefaultLightMode),
    #(#DefaultLightsFollowCamera, viewportSetting.DefaultLightsFollowCamera),
    #(#AutoDisplaySelectedLightEnabled, viewportSetting.AutoDisplaySelectedLightEnabled),
    #(#ShowHighlightEnabled, viewportSetting.ShowHighlightEnabled)
  )
)

fn CamWheel_CreateForcedViewportLightingState sourceLightingState =
(
  local forcedLightingState = #()

  if sourceLightingState != undefined do
  (
    for settingPair in sourceLightingState do append forcedLightingState settingPair
  )

  append forcedLightingState #(#LightOption, #DefaultLight)
  append forcedLightingState #(#DefaultLightMode, #TwoLights)
  append forcedLightingState #(#DefaultLightsFollowCamera, true)
  forcedLightingState
)

fn CamWheel_ApplyViewportLightingState viewportLightingState =
(
  if viewportLightingState == undefined then return false

  local viewportSetting = undefined
  try(viewportSetting = NitrousGraphicsManager.GetActiveViewportSetting())catch()
  if viewportSetting == undefined then return false

  for settingPair in viewportLightingState do
  (
    if settingPair != undefined and settingPair.count >= 2 do
    (
      case settingPair[1] of
      (
        #VisualStyleMode: try(viewportSetting.VisualStyleMode = settingPair[2])catch()
        #LightOption: try(viewportSetting.LightOption = settingPair[2])catch()
        #DefaultLightMode: try(viewportSetting.DefaultLightMode = settingPair[2])catch()
        #DefaultLightsFollowCamera: try(viewportSetting.DefaultLightsFollowCamera = settingPair[2])catch()
        #AutoDisplaySelectedLightEnabled: try(viewportSetting.AutoDisplaySelectedLightEnabled = settingPair[2])catch()
        #ShowHighlightEnabled: try(viewportSetting.ShowHighlightEnabled = settingPair[2])catch()
      )
    )
  )

  true
)

fn CamWheel_GetDefaultCameraExportSettings =
(
  local fallbackPresetLabel = CamWheel_GetAspectPresetLabelForSize renderWidth renderHeight
  local fallbackWidthValue = renderWidth
  local fallbackHeightValue = renderHeight
  local stateFilePath = CamWheel_GetGuideStateFilePath()
  local sectionName = CamWheel_GetGlobalExportSettingsSectionName()

  local presetLabel = getINISetting stateFilePath sectionName "aspect_preset"
  local widthValue = getINISetting stateFilePath sectionName "width"
  local heightValue = getINISetting stateFilePath sectionName "height"

  if presetLabel == undefined or presetLabel == "" do presetLabel = fallbackPresetLabel
  if widthValue == undefined or widthValue == "" then widthValue = fallbackWidthValue else widthValue = amax 1 (widthValue as integer)
  if heightValue == undefined or heightValue == "" then heightValue = fallbackHeightValue else heightValue = amax 1 (heightValue as integer)

  #(presetLabel, widthValue, heightValue)
)

fn CamWheel_SaveDefaultCameraExportSettings presetLabel widthValue heightValue =
(
  local stateFilePath = CamWheel_GetGuideStateFilePath()
  local sectionName = CamWheel_GetGlobalExportSettingsSectionName()

  setINISetting stateFilePath sectionName "aspect_preset" (presetLabel as string)
  setINISetting stateFilePath sectionName "width" ((amax 1 widthValue) as string)
  setINISetting stateFilePath sectionName "height" ((amax 1 heightValue) as string)
  true
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

  CamWheel_RunSingleFramePreviewExport normalizedPath
)

fn CamWheel_CanUseUserDefinedPreviewPreset =
(
  local versionInfo = maxVersion()
  versionInfo != undefined and versionInfo.count > 0 and versionInfo[1] >= 26000
)

fn CamWheel_GetDotNetGlobalInterface =
(
  if ::CamWheel_DotNetGlobalInterface != undefined then return ::CamWheel_DotNetGlobalInterface

  try(dotNet.loadAssembly "Autodesk.Max")catch()

  if ::CamWheel_DotNetGlobalInterface == undefined do
  (
    local globalInterfaceClass = undefined
    try(globalInterfaceClass = dotNetClass "Autodesk.Max.GlobalInterface")catch()
    if globalInterfaceClass != undefined do try(::CamWheel_DotNetGlobalInterface = globalInterfaceClass.Instance)catch()
  )

  ::CamWheel_DotNetGlobalInterface
)

fn CamWheel_GetPreviewCoreInterface =
(
  local globalInterface = CamWheel_GetDotNetGlobalInterface()
  local coreInterface = undefined

  if globalInterface == undefined then return undefined

  try(coreInterface = globalInterface.COREInterface14)catch()
  if coreInterface == undefined do try(coreInterface = globalInterface.COREInterface13)catch()
  if coreInterface == undefined do try(coreInterface = globalInterface.COREInterface)catch()
  coreInterface
)

fn CamWheel_GetDotNetPreviewParams coreInterface =
(
  local previewParams = undefined

  if coreInterface == undefined then return undefined

  try(previewParams = coreInterface.PreviewParams)catch()
  if previewParams == undefined do try(previewParams = coreInterface.GetPreviewParams())catch()
  previewParams
)

fn CamWheel_LogSdkCreatePreviewOverloads coreInterface =
(
  if coreInterface == undefined then return false

  local coreInterfaceType = undefined
  local methods = #()
  local matchedCount = 0

  try(coreInterfaceType = coreInterface.GetType())catch(coreInterfaceType = undefined)
  if coreInterfaceType == undefined then return false

  try(methods = coreInterfaceType.GetMethods())catch(methods = #())
  if methods == undefined then methods = #()

  for methodInfo in methods do
  (
    if methodInfo != undefined and methodInfo.Name == "CreatePreview" do
    (
      local parameterDescriptions = #()
      local methodParameters = #()

      try(methodParameters = methodInfo.GetParameters())catch(methodParameters = #())

      for parameterInfo in methodParameters do
      (
        local parameterTypeName = ""
        try(parameterTypeName = parameterInfo.ParameterType.FullName as string)catch(parameterTypeName = "")
        if parameterTypeName == "" do try(parameterTypeName = parameterInfo.ParameterType.Name as string)catch(parameterTypeName = "")
        if parameterTypeName == "" do parameterTypeName = "unknown"
        append parameterDescriptions parameterTypeName
      )

      format "CamWheel sdk CreatePreview overload -> %\n" (if parameterDescriptions.count > 0 then (parameterDescriptions as string) else "#()")
      matchedCount += 1
    )
  )

  matchedCount > 0
)

fn CamWheel_GetPreviewParamValue previewParams propertyName getterName =
(
  local propertyValue = undefined
  if previewParams == undefined then return undefined

  if propertyName != undefined do
  (
    try(propertyValue = getProperty previewParams propertyName)catch(propertyValue = undefined)
  )

  if propertyValue == undefined and getterName != undefined do
  (
    try(propertyValue = execute ("previewParams." + getterName + "()"))catch(propertyValue = undefined)
  )

  propertyValue
)

fn CamWheel_LogPreviewParamsSnapshot previewParams prefix:"snapshot" =
(
  local startValue = undefined
  local endValue = undefined
  local skipValue = undefined
  local pctSizeValue = undefined
  local outputTypeValue = undefined
  local fpsValue = undefined
  local dspSafeFrameValue = undefined
  local rangeTypeValue = undefined
  local customRangeValue = undefined
  local sourceTypeValue = undefined

  if previewParams == undefined then
  (
    format "CamWheel preview settings % -> unavailable\n" prefix
    return false
  )

  startValue = CamWheel_GetPreviewParamValue previewParams #Start "GetStart"
  endValue = CamWheel_GetPreviewParamValue previewParams #End "GetEnd"
  skipValue = CamWheel_GetPreviewParamValue previewParams #Skip "GetSkip"
  pctSizeValue = CamWheel_GetPreviewParamValue previewParams #PctSize "GetPctSize"
  outputTypeValue = CamWheel_GetPreviewParamValue previewParams #OutputType "GetOutputType"
  fpsValue = CamWheel_GetPreviewParamValue previewParams #FPS "GetFPS"
  dspSafeFrameValue = CamWheel_GetPreviewParamValue previewParams #DspSafeFrame "GetDspSafeFrame"
  rangeTypeValue = CamWheel_GetPreviewParamValue previewParams #RangeType "GetRangeType"
  customRangeValue = CamWheel_GetPreviewParamValue previewParams #CustomRange "GetCustomRange"
  sourceTypeValue = CamWheel_GetPreviewParamValue previewParams #SourceType "GetSourceType"

  format "CamWheel preview settings % -> Start:% End:% Skip:% PctSize:% OutputType:% FPS:% DspSafeFrame:% RangeType:% CustomRange:% SourceType:%\n" \
    prefix startValue endValue skipValue pctSizeValue outputTypeValue fpsValue dspSafeFrameValue rangeTypeValue customRangeValue sourceTypeValue
  true
)

fn CamWheel_ShouldLogPreviewImplementationMember memberName =
(
  local normalizedName = toLower (memberName as string)
  (findString normalizedName "start") != undefined or \
  (findString normalizedName "end") != undefined or \
  (findString normalizedName "range") != undefined or \
  (findString normalizedName "source") != undefined or \
  (findString normalizedName "type") != undefined or \
  (findString normalizedName "output") != undefined or \
  (findString normalizedName "skip") != undefined or \
  (findString normalizedName "fps") != undefined or \
  (findString normalizedName "pct") != undefined or \
  (findString normalizedName "safe") != undefined
)

fn CamWheel_LogPreviewImplementationDetails previewParams =
(
  local implementationValue = undefined
  local implementationType = undefined
  local propertyInfos = #()
  local methodInfos = #()

  if previewParams == undefined then return false

  try(implementationValue = previewParams.Implementation)catch(implementationValue = undefined)
  if implementationValue == undefined then return false

  try(implementationType = implementationValue.GetType())catch(implementationType = undefined)
  if implementationType == undefined then return false

  format "CamWheel preview implementation type -> %\n" (implementationType.FullName as string)

  try(propertyInfos = implementationType.GetProperties())catch(propertyInfos = #())
  for propertyInfo in propertyInfos do
  (
    if propertyInfo != undefined and CamWheel_ShouldLogPreviewImplementationMember propertyInfo.Name do
    (
      local propertyValue = undefined
      try(propertyValue = propertyInfo.GetValue implementationValue #())catch(propertyValue = undefined)
      format "CamWheel preview implementation property -> %:%\n" (propertyInfo.Name as string) propertyValue
    )
  )

  try(methodInfos = implementationType.GetMethods())catch(methodInfos = #())
  for methodInfo in methodInfos do
  (
    if methodInfo != undefined and CamWheel_ShouldLogPreviewImplementationMember methodInfo.Name do
      format "CamWheel preview implementation method -> %\n" (methodInfo.Name as string)
  )

  true
)

fn CamWheel_ShouldLogPreviewCoreMember memberName =
(
  local normalizedName = toLower (memberName as string)
  (findString normalizedName "preview") != undefined or \
  (findString normalizedName "range") != undefined or \
  (findString normalizedName "anim") != undefined or \
  (findString normalizedName "active") != undefined or \
  (findString normalizedName "segment") != undefined or \
  (findString normalizedName "time") != undefined or \
  (findString normalizedName "source") != undefined
)

fn CamWheel_LogPreviewCoreInterfaceDetails coreInterface =
(
  local coreInterfaceType = undefined
  local propertyInfos = #()
  local methodInfos = #()

  if coreInterface == undefined then return false

  try(coreInterfaceType = coreInterface.GetType())catch(coreInterfaceType = undefined)
  if coreInterfaceType == undefined then return false

  format "CamWheel preview core interface type -> %\n" (coreInterfaceType.FullName as string)

  try(propertyInfos = coreInterfaceType.GetProperties())catch(propertyInfos = #())
  for propertyInfo in propertyInfos do
  (
    if propertyInfo != undefined and CamWheel_ShouldLogPreviewCoreMember propertyInfo.Name do
    (
      local propertyValue = undefined
      try(propertyValue = propertyInfo.GetValue coreInterface #())catch(propertyValue = undefined)
      format "CamWheel preview core property -> %:%\n" (propertyInfo.Name as string) propertyValue
    )
  )

  try(methodInfos = coreInterfaceType.GetMethods())catch(methodInfos = #())
  for methodInfo in methodInfos do
  (
    if methodInfo != undefined and CamWheel_ShouldLogPreviewCoreMember methodInfo.Name do
    (
      local parameterDescriptions = #()
      local methodParameters = #()

      try(methodParameters = methodInfo.GetParameters())catch(methodParameters = #())
      for parameterInfo in methodParameters do
      (
        local parameterTypeName = ""
        try(parameterTypeName = parameterInfo.ParameterType.FullName as string)catch(parameterTypeName = "")
        if parameterTypeName == "" do try(parameterTypeName = parameterInfo.ParameterType.Name as string)catch(parameterTypeName = "")
        if parameterTypeName == "" do parameterTypeName = "unknown"
        append parameterDescriptions parameterTypeName
      )

      format "CamWheel preview core method -> % %\n" \
        (methodInfo.Name as string) \
        (if parameterDescriptions.count > 0 then (parameterDescriptions as string) else "#()")
    )
  )

  true
)

fn CamWheel_GetCoreAnimRangeSnapshot coreInterface =
(
  local animRange = undefined
  local startValue = undefined
  local endValue = undefined

  if coreInterface == undefined then return #(undefined, undefined, undefined)

  try(animRange = coreInterface.AnimRange)catch(animRange = undefined)
  if animRange == undefined then return #(undefined, undefined, undefined)

  try(startValue = animRange.Start)catch(try(startValue = animRange.GetStart())catch(startValue = undefined))
  try(endValue = animRange.End)catch(try(endValue = animRange.GetEnd())catch(endValue = undefined))
  #(animRange, startValue, endValue)
)

fn CamWheel_ApplyCoreSingleFramePreviewRange coreInterface frameNumber =
(
  local animRangeSnapshot = CamWheel_GetCoreAnimRangeSnapshot coreInterface
  local animRange = animRangeSnapshot[1]
  local beforeStart = animRangeSnapshot[2]
  local beforeEnd = animRangeSnapshot[3]
  local rangeApplied = false

  format "CamWheel core anim range before -> Start:% End:%\n" beforeStart beforeEnd

  if coreInterface == undefined then return false

  try
  (
    if animRange != undefined then
    (
      try(animRange.Start = frameNumber)catch(try(animRange.SetStart frameNumber)catch())
      try(animRange.End = frameNumber)catch(try(animRange.SetEnd frameNumber)catch())
      try(coreInterface.AnimRange = animRange)catch()
    )

    try(coreInterface.SetTime frameNumber false)catch()
    rangeApplied = true
  )
  catch
  (
    format "CamWheel core anim range apply failed -> error:%\n" (getCurrentException())
    rangeApplied = false
  )

  animRangeSnapshot = CamWheel_GetCoreAnimRangeSnapshot coreInterface
  format "CamWheel core anim range after -> Start:% End:%\n" animRangeSnapshot[2] animRangeSnapshot[3]
  rangeApplied
)

fn CamWheel_ApplyLegacyPreviewSettingsForFrame previewFrameNumber =
(
  local coreInterface = CamWheel_GetPreviewCoreInterface()
  local previewParams = CamWheel_GetDotNetPreviewParams coreInterface

  if previewParams == undefined then return false

  try
  (
    try(previewParams.SetStart previewFrameNumber)catch(try(previewParams.Start = previewFrameNumber)catch())
    try(previewParams.SetEnd previewFrameNumber)catch(try(previewParams.End = previewFrameNumber)catch())
    try(previewParams.SetSkip 1)catch(try(previewParams.Skip = 1)catch())
    try(previewParams.SetPctSize 100)catch(try(previewParams.PctSize = 100)catch())
    try(previewParams.SetDspSafeFrame false)catch(try(previewParams.DspSafeFrame = false)catch())
    try(previewParams.SetOutputType 1)catch(try(previewParams.OutputType = 1)catch())
    try(previewParams.SetFPS frameRate)catch(try(previewParams.FPS = frameRate)catch())
    CamWheel_ApplyCoreSingleFramePreviewRange coreInterface previewFrameNumber
    CamWheel_UseCurrentPreviewSettingsOnce = true
    format "CamWheel preview settings requested -> start:% end:% skip:1 output:frames\n" previewFrameNumber previewFrameNumber
    CamWheel_LogPreviewParamsSnapshot previewParams prefix:"readback"
    CamWheel_LogPreviewImplementationDetails previewParams
    true
  )
  catch
  (
    format "CamWheel preview settings apply failed -> error:%\n" (getCurrentException())
    false
  )
)

fn CamWheel_ApplyLegacySingleFramePreviewSettings =
(
  CamWheel_ApplyLegacyPreviewSettingsForFrame 0
)

fn CamWheel_RunPreviewWithCurrentSettings exportPath =
(
  local coreInterface = CamWheel_GetPreviewCoreInterface()
  local previewFrameNumber = sliderTime.frame as integer

  format "CamWheel preview mode -> current settings\n"
  CamWheel_ApplyCoreSingleFramePreviewRange coreInterface previewFrameNumber
  createPreview \
    filename:exportPath \
    outputAVI:false
  true
)

fn CamWheel_OpenNativePreviewDialog =
(
  format "CamWheel preview dialog open\n"
  max preview
  true
)

fn CamWheel_LogCurrentPreviewSettings =
(
  local coreInterface = CamWheel_GetPreviewCoreInterface()
  local previewParams = CamWheel_GetDotNetPreviewParams coreInterface
  local previewParamsType = undefined
  local propertyInfos = #()
  local methodInfos = #()

  if previewParams == undefined then
  (
    format "CamWheel preview settings snapshot -> unavailable\n"
    return false
  )

  CamWheel_LogPreviewParamsSnapshot previewParams prefix:"snapshot"
  CamWheel_LogPreviewImplementationDetails previewParams
  CamWheel_LogPreviewCoreInterfaceDetails coreInterface

  try(previewParamsType = previewParams.GetType())catch(previewParamsType = undefined)
  if previewParamsType == undefined then return true

  try(propertyInfos = previewParamsType.GetProperties())catch(propertyInfos = #())
  for propertyInfo in propertyInfos do
  (
    if propertyInfo != undefined do format "CamWheel preview settings property -> %\n" (propertyInfo.Name as string)
  )

  try(methodInfos = previewParamsType.GetMethods())catch(methodInfos = #())
  for methodInfo in methodInfos do
  (
    if methodInfo != undefined and matchPattern (methodInfo.Name as string) pattern:"Get*" do
      format "CamWheel preview settings method -> %\n" (methodInfo.Name as string)
  )

  true
)

fn CamWheel_RunPreviewWithLegacyDialogParams exportPath previewFrameNumber =
(
  local coreInterface = CamWheel_GetPreviewCoreInterface()
  local previewParams = CamWheel_GetDotNetPreviewParams coreInterface
  local originalStart = undefined
  local originalEnd = undefined
  local originalSkip = undefined
  local originalPctSize = undefined
  local originalDspSafeFrame = undefined
  local originalOutputType = undefined
  local exportSucceeded = false

  if previewParams == undefined then return false

  format "CamWheel preview mode -> legacy dialog params\n"

  try(originalStart = previewParams.Start)catch(try(originalStart = previewParams.GetStart())catch())
  try(originalEnd = previewParams.End)catch(try(originalEnd = previewParams.GetEnd())catch())
  try(originalSkip = previewParams.Skip)catch(try(originalSkip = previewParams.GetSkip())catch())
  try(originalPctSize = previewParams.PctSize)catch(try(originalPctSize = previewParams.GetPctSize())catch())
  try(originalDspSafeFrame = previewParams.DspSafeFrame)catch(try(originalDspSafeFrame = previewParams.GetDspSafeFrame())catch())
  try(originalOutputType = previewParams.OutputType)catch(try(originalOutputType = previewParams.GetOutputType())catch())

  try
  (
    try(previewParams.SetStart previewFrameNumber)catch(try(previewParams.Start = previewFrameNumber)catch())
    try(previewParams.SetEnd previewFrameNumber)catch(try(previewParams.End = previewFrameNumber)catch())
    try(previewParams.SetSkip 1)catch(try(previewParams.Skip = 1)catch())
    try(previewParams.SetPctSize 100)catch(try(previewParams.PctSize = 100)catch())
    try(previewParams.SetDspSafeFrame false)catch(try(previewParams.DspSafeFrame = false)catch())
    try(previewParams.SetOutputType 1)catch(try(previewParams.OutputType = 1)catch())

    createPreview \
      filename:exportPath \
      outputAVI:false
    exportSucceeded = true
  )
  catch
  (
    format "CamWheel legacy dialog params failed -> error:%\n" (getCurrentException())
    exportSucceeded = false
  )

  if originalStart != undefined do try(previewParams.SetStart originalStart)catch(try(previewParams.Start = originalStart)catch())
  if originalEnd != undefined do try(previewParams.SetEnd originalEnd)catch(try(previewParams.End = originalEnd)catch())
  if originalSkip != undefined do try(previewParams.SetSkip originalSkip)catch(try(previewParams.Skip = originalSkip)catch())
  if originalPctSize != undefined do try(previewParams.SetPctSize originalPctSize)catch(try(previewParams.PctSize = originalPctSize)catch())
  if originalDspSafeFrame != undefined do try(previewParams.SetDspSafeFrame originalDspSafeFrame)catch(try(previewParams.DspSafeFrame = originalDspSafeFrame)catch())
  if originalOutputType != undefined do try(previewParams.SetOutputType originalOutputType)catch(try(previewParams.OutputType = originalOutputType)catch())

  exportSucceeded
)

fn CamWheel_RunPreviewWithLegacyExplicitRange exportPath previewFrameNumber =
(
  format "CamWheel preview mode -> legacy explicit range\n"
  createPreview \
    filename:exportPath \
    outputAVI:false \
    percentSize:100 \
    start:previewFrameNumber \
    end:previewFrameNumber \
    skip:1 \
    fps:frameRate \
    dspSafeFrame:false
  true
)

fn CamWheel_RunPreviewWithSdkIntPtr exportPath previewFrameNumber =
(
  local coreInterface = CamWheel_GetPreviewCoreInterface()
  local previewParams = CamWheel_GetDotNetPreviewParams coreInterface
  local marshalClass = undefined
  local intPtrClass = undefined
  local filenamePtr = undefined
  local snippetPtr = undefined
  local exportSucceeded = false

  if coreInterface == undefined or previewParams == undefined then return false

  format "CamWheel preview mode -> sdk intptr\n"

  try(marshalClass = dotNetClass "System.Runtime.InteropServices.Marshal")catch(marshalClass = undefined)
  try(intPtrClass = dotNetClass "System.IntPtr")catch(intPtrClass = undefined)
  if marshalClass == undefined or intPtrClass == undefined then return false

  try(previewParams.SetStart previewFrameNumber)catch(try(previewParams.Start = previewFrameNumber)catch())
  try(previewParams.SetEnd previewFrameNumber)catch(try(previewParams.End = previewFrameNumber)catch())
  try(previewParams.SetSkip 1)catch(try(previewParams.Skip = 1)catch())
  try(previewParams.SetPctSize 100)catch(try(previewParams.PctSize = 100)catch())
  try(previewParams.SetDspSafeFrame false)catch(try(previewParams.DspSafeFrame = false)catch())
  try(previewParams.SetOutputType 1)catch(try(previewParams.OutputType = 1)catch())

  try(filenamePtr = marshalClass.StringToHGlobalUni exportPath)catch(filenamePtr = undefined)
  try(snippetPtr = intPtrClass.Zero)catch(snippetPtr = undefined)

  if filenamePtr == undefined or snippetPtr == undefined then
  (
    if filenamePtr != undefined do try(marshalClass.FreeHGlobal filenamePtr)catch()
    return false
  )

  try
  (
    coreInterface.CreatePreview previewParams filenamePtr snippetPtr
    exportSucceeded = true
  )
  catch
  (
    format "CamWheel sdk intptr failed -> error:%\n" (getCurrentException())
    exportSucceeded = false
  )

  try(marshalClass.FreeHGlobal filenamePtr)catch()
  exportSucceeded
)

fn CamWheel_RunPreviewWithSdkParams exportPath previewFrameNumber =
(
  local coreInterface = CamWheel_GetPreviewCoreInterface()
  local previewParams = CamWheel_GetDotNetPreviewParams coreInterface
  local createPreviewSucceeded = false
  local overloadsLogged = false

  if coreInterface == undefined or previewParams == undefined then return false

  format "CamWheel preview mode -> sdk preview params\n"

  try(previewParams.SetStart previewFrameNumber)catch(try(previewParams.Start = previewFrameNumber)catch())
  try(previewParams.SetEnd previewFrameNumber)catch(try(previewParams.End = previewFrameNumber)catch())
  try(previewParams.SetSkip 1)catch(try(previewParams.Skip = 1)catch())
  try(previewParams.SetPctSize 100)catch(try(previewParams.PctSize = 100)catch())
  try(previewParams.SetDspSafeFrame false)catch(try(previewParams.DspSafeFrame = false)catch())
  try(previewParams.SetOutputType 1)catch(try(previewParams.OutputType = 1)catch(try(previewParams.SetOutputType true)catch()))

  try
  (
    coreInterface.CreatePreview previewParams exportPath
    createPreviewSucceeded = true
  )
  catch
  (
    try
    (
      coreInterface.CreatePreview previewParams exportPath undefined
      createPreviewSucceeded = true
    )
    catch
    (
      try
      (
        coreInterface.CreatePreview previewParams exportPath "" 
        createPreviewSucceeded = true
      )
      catch
      (
        overloadsLogged = CamWheel_LogSdkCreatePreviewOverloads coreInterface
        format "CamWheel sdk preview fallback failed -> error:%\n" (getCurrentException())
        if overloadsLogged == false do format "CamWheel sdk CreatePreview overload -> unavailable\n"
        createPreviewSucceeded = false
      )
    )
  )

  createPreviewSucceeded
)

fn CamWheel_RunPreviewWithUserDefinedPreset exportPath previewFrameNumber =
(
  format "CamWheel preview mode -> userdefined\n"
  createPreview \
    filename:exportPath \
    outputAVI:false \
    start:previewFrameNumber \
    end:previewFrameNumber \
    skip:1 \
    dspSafeFrame:false \
    autoPlay:false \
    vpPreset:#userdefined
  true
)

fn CamWheel_RunPreviewWithLegacyDefaults exportPath previewFrameNumber =
(
  format "CamWheel preview mode -> legacy default\n"
  format "CamWheel legacy preview fallback -> current preview defaults\n"
  createPreview \
    filename:exportPath \
    outputAVI:false \
    start:previewFrameNumber \
    end:previewFrameNumber \
    skip:1 \
    dspSafeFrame:false
  true
)

fn CamWheel_RunSingleFramePreviewExport exportPath =
(
  local normalizedPath = CamWheel_NormalizeExportPath exportPath
  if normalizedPath == undefined then return false

  local previewFrameTime = sliderTime
  local previewFrameNumber = previewFrameTime.frame as integer
  local exportSucceeded = false

  jpeg.ijpegio.setQuality 100

  -- Native preview wrapper contract:
  -- current active viewport only
  -- tools -> preview grab viewport -> create preview animation
  -- single frame at current timeline frame
  -- visual style Standard
  -- output .jpg
  format "CamWheel native preview export -> file:% viewport:% frames:% style:%\n" \
    normalizedPath \
    "current active viewport" \
    ((previewFrameNumber as string) + "-" + (previewFrameNumber as string) + " (single frame)") \
    "Standard"

  try
  (
    if CamWheel_UseCurrentPreviewSettingsOnce then
    (
      CamWheel_UseCurrentPreviewSettingsOnce = false
      exportSucceeded = CamWheel_RunPreviewWithCurrentSettings normalizedPath
    )
    else
    (
      if CamWheel_CanUseUserDefinedPreviewPreset() then
      (
        try
        (
          exportSucceeded = CamWheel_RunPreviewWithUserDefinedPreset normalizedPath previewFrameNumber
        )
        catch
        (
          exportSucceeded = CamWheel_RunPreviewWithLegacyDefaults normalizedPath previewFrameNumber
        )
      )
      else
      (
        if CamWheel_ApplyLegacyPreviewSettingsForFrame previewFrameNumber then
        (
          CamWheel_UseCurrentPreviewSettingsOnce = false
          exportSucceeded = CamWheel_RunPreviewWithCurrentSettings normalizedPath
        )
        else
        (
          try
          (
            exportSucceeded = CamWheel_RunPreviewWithSdkIntPtr normalizedPath previewFrameNumber
          )
          catch
          (
            try
            (
              exportSucceeded = CamWheel_RunPreviewWithLegacyExplicitRange normalizedPath previewFrameNumber
            )
            catch
            (
              try
              (
                exportSucceeded = CamWheel_RunPreviewWithLegacyDialogParams normalizedPath previewFrameNumber
              )
              catch
              (
                try
                (
                  exportSucceeded = CamWheel_RunPreviewWithSdkParams normalizedPath previewFrameNumber
                )
                catch
                (
                  exportSucceeded = CamWheel_RunPreviewWithLegacyDefaults normalizedPath previewFrameNumber
                )
              )
            )
          )
        )
      )
    )
  )
  catch
  (
    CamWheel_UseCurrentPreviewSettingsOnce = false
    format "CamWheel native preview export failed -> error:%\n" (getCurrentException())
    exportSucceeded = false
  )

  if exportSucceeded == false and CamWheel_DidExportWriteFile normalizedPath do
  (
    format "CamWheel native preview export recovered -> file detected:%\n" normalizedPath
    exportSucceeded = true
  )
  exportSucceeded
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
  local exportSucceeded = false
  local viewportLightingState = CamWheel_CaptureViewportLightingState()
  local forceDefaultTwoLights = CamWheel_GetGuideState #force_default_two_lights_on_export true
  local forcedLightingState = if forceDefaultTwoLights then (CamWheel_CreateForcedViewportLightingState viewportLightingState) else viewportLightingState

  try
  (
    CamWheel_ApplyCameraExportSettings cameraNode
    viewport.setCamera cameraNode
    CamWheel_ApplyViewportLightingState forcedLightingState
    CamWheel_StabilizeViewportForExport()
    CamWheel_SetGuideState #guides_visible false
    CamWheel_RedrawGuides()
    CamWheel_ApplyViewportLightingState forcedLightingState
    CamWheel_StabilizeViewportForExport()
    exportSucceeded = CamWheel_RunNativePreviewExport normalizedPath
    CamWheel_ApplyViewportLightingState viewportLightingState
    CamWheel_SetGuideState #guides_visible originalGuideVisibility
    CamWheel_RedrawGuides()
    if exportSucceeded == false and CamWheel_DidExportWriteFile normalizedPath do
    (
      format "CamWheel camera export recovered -> camera:% file:%\n" cameraNode.name normalizedPath
      exportSucceeded = true
    )
    exportSucceeded
  )
  catch
  (
    CamWheel_ApplyViewportLightingState viewportLightingState
    CamWheel_SetGuideState #guides_visible originalGuideVisibility
    CamWheel_RedrawGuides()
    if CamWheel_DidExportWriteFile normalizedPath then
    (
      format "CamWheel camera export recovered after exception -> camera:% file:% error:%\n" cameraNode.name normalizedPath (getCurrentException())
      true
    )
    else
    (
      throw()
    )
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

    format "CamWheel batch export -> camera:% path:%\n" cameraNode.name exportPath
    try
    (
      if CamWheel_ExportViewportForCamera cameraNode exportPath then
      (
        format "CamWheel batch export success -> camera:%\n" cameraNode.name
        successCount += 1
      )
      else
      (
        format "CamWheel batch export failed -> camera:% reason:%\n" cameraNode.name "returned false"
        append failedCameraNames cameraNode.name
      )
    )
    catch
    (
      format "CamWheel batch export failed -> camera:% error:%\n" cameraNode.name (getCurrentException())
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

  format "CamWheel batch export summary -> success:% failed:% directory:%\n" successCount failureCount resultDirectory
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
