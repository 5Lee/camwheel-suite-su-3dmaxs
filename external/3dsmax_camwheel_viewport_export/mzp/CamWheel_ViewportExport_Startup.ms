fn CamWheel_LoadInstalledStartupScript =
(
  local camwheelScriptsRoot = pathConfig.appendPath (getDir #scripts) "3dsmax_camwheel_viewport_export"
  local camwheelEntryScript = pathConfig.appendPath camwheelScriptsRoot "CamWheel_ViewportExport.ms"

  if doesFileExist camwheelEntryScript do
  (
    fileIn camwheelEntryScript
  )
)

CamWheel_LoadInstalledStartupScript()
