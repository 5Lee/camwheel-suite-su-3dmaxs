fn CamWheel_LoadInstalledStartupScript =
(
  local camwheelScriptsRoot = pathConfig.appendPath (getDir #scripts) "3dsmax_camwheel_viewport_export"
  local camwheelEntryScript = pathConfig.appendPath camwheelScriptsRoot "CamWheel_ViewportExport.ms"

  if doesFileExist camwheelEntryScript do
  (
    try
    (
      format "CamWheel startup load -> script:%\n" camwheelEntryScript
      fileIn camwheelEntryScript
    )
    catch
    (
      format "CamWheel startup load failed -> error:%\n" (getCurrentException())
    )
  )

  if doesFileExist camwheelEntryScript == false do
    format "CamWheel startup load skipped -> missing script:%\n" camwheelEntryScript
)

CamWheel_LoadInstalledStartupScript()
