require_relative "../test_helper"

class ThreeDsMaxViewportExportStructureTest < Minitest::Test
  def test_plugin_files_exist
    assert File.exist?(entry_file("CamWheel_ViewportExport.ms"))
    assert File.exist?(entry_file("export.ms"))
    assert File.exist?(entry_file("guides.ms"))
    assert File.exist?(entry_file("panel.ms"))
    assert File.exist?(entry_file("install.txt"))
    assert File.exist?(entry_file("LICENSE"))
    assert File.exist?(entry_file("icons/camwheel_panel.svg"))
    assert File.exist?(entry_file("icons/camwheel_panel_24.png"))
    assert File.exist?(entry_file("icons/camwheel_panel_30.png"))
    assert File.exist?(package_file("mzp.run"))
    assert File.exist?(package_file("install.ms"))
    assert File.exist?(package_file("CamWheel_ViewportExport_Startup.ms"))
  end

  def test_main_script_defines_macro_and_shared_entry_points
    script = File.read(entry_file("CamWheel_ViewportExport.ms"))

    refute_match(/\Alocal\s+/m, script)
    refute_includes script, "local camwheelRoot ="
    assert_includes script, "构图辅助"
    assert_includes script, "光影图像"
    assert_includes script, "GPL-3.0"
    assert_includes script, "CamWheel_ShowAbout"
    assert_includes script, "local aboutText ="
    assert_includes script, "messageBox aboutText title:CamWheel_PluginName"
    assert_includes script, "macroScript"
    assert_includes script, "CamWheel"
    assert_includes script, "CamWheel_ExportActiveViewport"
    assert_includes script, "CamWheel_ShowPanel"
    assert_includes script, "CamWheel_ToggleGuides"
    assert_includes script, "macroScript CamWheel_MainPanel"
    assert_includes script, "fn CamWheel_LoadModules"
    assert_includes script, "fn CamWheel_RegisterModernContextMenuCallback"
    assert_includes script, "CamWheel_RegisterLegacyContextMenu"
    assert_includes script, "CamWheel_RegisterModernContextMenu"
    assert_includes script, "CamWheel_EnsureToolbarIcons"
    assert_includes script, "getDir #userIcons"
    assert_includes script, "Light"
    assert_includes script, "Dark"
    assert_includes script, "iconName:\"CamWheel/camwheel_panel\""
    assert_includes script, "copyFile"
    assert_includes script, "try(callbacks.addScript #cuiRegisterQuadMenus"
    assert_includes script, "menuMan.registerMenuContext"
    assert_includes script, "getViewportRightClickMenu"
    assert_includes script, "createActionItem"
    assert_includes script, "\"导出当前视口\""
    assert_includes script, "\"显示/隐藏辅助线\""
    assert_includes script, "\"打开面板\""
    assert_includes script, "\"CamWheel 控制面板\""
    refute_includes script, "CamWheel_ShowPanel()\nCamWheel_InstallContextMenus()"
  end

  def test_export_script_defines_native_export_hooks
    script = File.read(entry_file("export.ms"))

    assert_includes script, "global CamWheel_GetSceneCameras"
    assert_includes script, "global CamWheel_RequestBatchExportDirectory"
    assert_includes script, "global CamWheel_ExportViewportForCamera"
    assert_includes script, "global CamWheel_ExportSelectedCameras"
    assert_includes script, "global CamWheel_GetGuideState"
    assert_includes script, "global CamWheel_SetGuideState"
    assert_includes script, "global CamWheel_RedrawGuides"
    assert_includes script, "CamWheel_FormatTimestamp"
    assert_includes script, "getLocalTime()"
    assert_includes script, "timeParts[1]"
    assert_includes script, "timeParts[2]"
    assert_includes script, "timeParts[3]"
    assert_includes script, "timeParts[5]"
    assert_includes script, "timeParts[6]"
    assert_includes script, "timeParts[7]"
    assert_includes script, "CamWheel_DefaultExportFilename"
    assert_includes script, "CamWheel_RequestExportPath"
    assert_includes script, "CamWheel_RequestBatchExportDirectory"
    assert_includes script, "CamWheel_RunNativePreviewExport"
    assert_includes script, "CamWheel_ExportViewportForCamera"
    assert_includes script, "CamWheel_ExportSelectedCameras"
    assert_includes script, "CamWheel_ExportActiveViewport"
    assert_includes script, "CamWheel_ShowExportSuccess"
    assert_includes script, "CamWheel_ShowExportCanceled"
    assert_includes script, "CamWheel_ShowExportFailure"
    assert_includes script, "CamWheel_SanitizeExportNamePart"
    assert_includes script, "CamWheel_BuildBatchExportFilename"
    assert_includes script, "CamWheel_ResolveUniqueExportPath"
    assert_includes script, "CamWheel_CompareCameraNodesByName"
    assert_includes script, "CamWheel_GetDefaultCameraExportSettings"
    assert_includes script, "CamWheel_GetCameraExportSettings"
    assert_includes script, "CamWheel_SaveCameraExportSettings"
    assert_includes script, "CamWheel_ApplyCameraExportSettings"
    assert_includes script, "camera."
    assert_includes script, "aspect_preset"
    assert_includes script, "width"
    assert_includes script, "height"
    refute_includes script, "fn leftNode rightNode"
    assert_includes script, "getSaveFileName"
    assert_includes script, "getSavePath"
    assert_includes script, "camwheel"
    assert_includes script, "sceneName + \"-\" + cameraName + \".jpg\""
    assert_includes script, "0-0"
    assert_includes script, "native preview"
    assert_includes script, "createPreview"
    assert_includes script, "outputAVI:false"
    assert_includes script, "start:0"
    assert_includes script, "end:0"
    assert_includes script, "dspSafeFrame:false"
    assert_includes script, "autoPlay:false"
    assert_includes script, "vpPreset:#userdefined"
    assert_includes script, "jpegio.setQuality 100"
    assert_includes script, "Standard"
    assert_includes script, ".jpg"
  end

  def test_guide_script_defines_overlay_state_and_toggle_hooks
    script = File.read(entry_file("guides.ms"))

    assert_includes script, "global CamWheel_GuideStateFilePath"
    assert_includes script, "show_rule_of_thirds"
    assert_includes script, "show_center_cross"
    assert_includes script, "show_diagonals"
    assert_includes script, "CamWheel_ToggleGuides"
    assert_includes script, "CamWheel_SetAllGuides"
    assert_includes script, "CamWheel_DefaultGuideState"
    assert_includes script, "CamWheel_LoadGuideState"
    assert_includes script, "CamWheel_SaveGuideState"
    assert_includes script, "CamWheel_SetGuideStateAndPersist"
    assert_includes script, "getINISetting"
    assert_includes script, "setINISetting"
    assert_includes script, "#guides_visible, false"
    assert_includes script, "CamWheel_RedrawGuides"
    assert_includes script, "registerRedrawViewsCallback"
    assert_includes script, "unRegisterRedrawViewsCallback"
    assert_includes script, "gw.getWinSizeX"
    assert_includes script, "gw.getWinSizeY"
    assert_includes script, "gw.wPolyline"
    assert_includes script, "gw.setColor"
    assert_includes script, "gw.enlargeUpdateRect #whole"
    assert_includes script, "gw.updateScreen"
    assert_includes script, "CamWheel_GetSafeFrameRect"
    assert_includes script, "renderWidth"
    assert_includes script, "renderHeight"
  end

  def test_panel_script_defines_rollout_controls
    script = File.read(entry_file("panel.ms"))

    assert_includes script, "rollout"
    assert_includes script, "CamWheel 控制面板"
    assert_includes script, "相机批量截图"
    assert_includes script, "dotNetControl"
    assert_includes script, "System.Windows.Forms.CheckedListBox"
    assert_includes script, "刷新列表"
    assert_includes script, "全选"
    assert_includes script, "反选"
    assert_includes script, "批量导出选中相机"
    assert_includes script, "导出当前视口"
    assert_includes script, "显示辅助线"
    assert_includes script, "比例预设"
    assert_includes script, "锁定比例"
    assert_includes script, "宽度"
    assert_includes script, "高度"
    assert_includes script, "快捷分辨率"
    assert_includes script, "\"1024\""
    assert_includes script, "\"1920\""
    assert_includes script, "\"2048\""
    assert_includes script, "\"3840\""
    assert_includes script, "关于"
    assert_includes script, "三分线"
    assert_includes script, "中心线"
    assert_includes script, "对角线"
    refute_includes script, "全部开启"
    refute_includes script, "全部关闭"
    assert_includes script, "CamWheel_SyncPanelState"
    assert_includes script, "CamWheel_UpdateGuideToggleAvailability"
    assert_includes script, "thirdsToggle.enabled = guidesVisibleValue"
    assert_includes script, "centerToggle.enabled = guidesVisibleValue"
    assert_includes script, "diagonalsToggle.enabled = guidesVisibleValue"
    assert_includes script, "CamWheel_RoundPositive"
    assert_includes script, "CamWheel_SyncRenderSettingsFromPanel"
    assert_includes script, "CamWheel_PanelRefreshCameraList"
    assert_includes script, "CamWheel_PanelSelectAllCameras"
    assert_includes script, "CamWheel_PanelInvertCameraSelection"
    assert_includes script, "CamWheel_PanelGetSelectedCameras"
    assert_includes script, "CamWheel_PanelSelectedCameraIndex"
    assert_includes script, "CamWheel_PanelSyncSelectedCameraSettings"
    assert_includes script, "CamWheel_PanelApplySelectedCameraSettings"
    assert_includes script, "CamWheel_PanelFormatCameraListItem"
    assert_includes script, "当前选中相机设置"
    assert_includes script, "应用到当前相机"
    assert_includes script, "createDialog CamWheelPanelRollout 420 390"
    assert_includes script, "CamWheel_GetGuideState"
    assert_includes script, "CamWheel_ReadRenderSettings"
    assert_includes script, "CamWheel_ApplyRenderSettings"
    assert_includes script, "rendLockImageAspectRatio = true"
    assert_includes script, "rendImageAspectRatio ="
    assert_includes script, "renderSceneDialog.isOpen()"
    assert_includes script, "renderSceneDialog.update()"
    assert_includes script, "CamWheel_SetGuideStateAndPersist #guides_visible state"
    assert_includes script, "CamWheel_SetGuideStateAndPersist #show_rule_of_thirds state"
    assert_includes script, "CamWheel_SetGuideStateAndPersist #show_center_cross state"
    assert_includes script, "CamWheel_SetGuideStateAndPersist #show_diagonals state"
    assert_includes script, "renderWidth"
    assert_includes script, "renderHeight"
  end

  def test_install_notes_reference_toolbar_menu_and_panel
    notes = File.read(entry_file("install.txt"))

    assert_includes notes, "工具栏"
    assert_includes notes, "右键菜单"
    assert_includes notes, "独立小面板"
    assert_includes notes, "场景名-时间戳.jpg"
    assert_includes notes, "CamWheel / CamWheel_ViewportExport"
    assert_includes notes, "CamWheel / CamWheel_ToggleGuides"
    assert_includes notes, "CamWheel / CamWheel_OpenPanel"
    assert_includes notes, "CamWheel / CamWheel_MainPanel"
    assert_includes notes, "SVG"
    assert_includes notes, "Customize User Interface"
    assert_includes notes, "拖到工具栏"
    assert_includes notes, "#userIcons"
    assert_includes notes, "自动复制"
    assert_includes notes, "构图辅助"
    assert_includes notes, "光影图像"
    assert_includes notes, "GPL-3.0"
    assert_includes notes, "相机批量截图"
    assert_includes notes, "刷新列表"
    assert_includes notes, "全选"
    assert_includes notes, "反选"
    assert_includes notes, "批量导出选中相机"
    assert_includes notes, "场景名-相机名.jpg"
    assert_includes notes, "首次默认关闭"
    assert_includes notes, "记住上一次"
    assert_includes notes, "camwheel_guides_state.ini"
    assert_includes notes, "当前选中相机设置"
    assert_includes notes, "应用到当前相机"
    assert_includes notes, "每个相机独立"
    assert_includes notes, "比例预设 + 宽度 + 高度"
  end

  def test_license_file_is_gpl_3_0
    license_text = File.read(entry_file("LICENSE"))

    assert_includes license_text, "GNU GENERAL PUBLIC LICENSE"
    assert_includes license_text, "Version 3, 29 June 2007"
    assert_includes license_text, "光影图像"
  end

  def test_manual_checklist_covers_export_contract
    notes = File.read(File.expand_path("../../docs/manual-test-checklist-3dsmax.md", __dir__))

    assert_includes notes, "当前激活视口"
    assert_includes notes, "原生预览抓取"
    assert_includes notes, "0-0"
    assert_includes notes, "Standard"
    assert_includes notes, "未保存场景"
    assert_includes notes, "camwheel-"
    assert_includes notes, "取消保存"
    assert_includes notes, "CamWheel 子菜单"
    assert_includes notes, "导出当前视口"
    assert_includes notes, "显示/隐藏辅助线"
    assert_includes notes, "打开面板"
    assert_includes notes, "安全框内"
    assert_includes notes, "默认读取当前渲染设置"
    assert_includes notes, "自动同步到渲染设置"
    assert_includes notes, "相机列表自动读取"
    assert_includes notes, "批量导出选中相机"
    assert_includes notes, "场景名-相机名.jpg"
    assert_includes notes, "全选"
    assert_includes notes, "反选"
    assert_includes notes, "刷新列表"
    assert_includes notes, "重名"
    assert_includes notes, "删除状态文件"
    assert_includes notes, "首次默认关闭"
    assert_includes notes, "记住上一次"
    assert_includes notes, "当前选中相机设置"
    assert_includes notes, "应用到当前相机"
    assert_includes notes, "每个相机独立"
    refute_includes notes, "全部开启 / 全部关闭"
  end

  def test_readme_mentions_batch_camera_export
    notes = File.read(entry_file("README.md"))

    assert_includes notes, "相机批量截图"
    assert_includes notes, "批量导出选中相机"
    assert_includes notes, "场景名-相机名.jpg"
    assert_includes notes, "刷新列表"
    assert_includes notes, "全选"
    assert_includes notes, "反选"
    assert_includes notes, "首次默认关闭"
    assert_includes notes, "记住上一次"
    assert_includes notes, "camwheel_guides_state.ini"
    assert_includes notes, "当前选中相机设置"
    assert_includes notes, "应用到当前相机"
    assert_includes notes, "每个相机独立"
    assert_includes notes, "比例预设 + 宽度 + 高度"
  end

  def test_mzp_package_recipe_installs_scripts_and_startup_loader
    recipe = File.read(package_file("mzp.run"))

    assert_includes recipe, "name \"CamWheel 3ds Max Viewport Export\""
    assert_includes recipe, "copy \"scripts\\\\3dsmax_camwheel_viewport_export\\\\CamWheel_ViewportExport.ms\" to \"$scripts\\\\3dsmax_camwheel_viewport_export\""
    assert_includes recipe, "copy \"scripts\\\\3dsmax_camwheel_viewport_export\\\\export.ms\" to \"$scripts\\\\3dsmax_camwheel_viewport_export\""
    assert_includes recipe, "copy \"scripts\\\\3dsmax_camwheel_viewport_export\\\\guides.ms\" to \"$scripts\\\\3dsmax_camwheel_viewport_export\""
    assert_includes recipe, "copy \"scripts\\\\3dsmax_camwheel_viewport_export\\\\panel.ms\" to \"$scripts\\\\3dsmax_camwheel_viewport_export\""
    assert_includes recipe, "copy \"scripts\\\\3dsmax_camwheel_viewport_export\\\\LICENSE\" to \"$scripts\\\\3dsmax_camwheel_viewport_export\""
    assert_includes recipe, "copy \"scripts\\\\3dsmax_camwheel_viewport_export\\\\icons\\\\camwheel_panel.svg\" to \"$scripts\\\\3dsmax_camwheel_viewport_export\\\\icons\""
    assert_includes recipe, "copy \"scripts\\\\3dsmax_camwheel_viewport_export\\\\icons\\\\camwheel_panel_24.png\" to \"$scripts\\\\3dsmax_camwheel_viewport_export\\\\icons\""
    assert_includes recipe, "copy \"scripts\\\\3dsmax_camwheel_viewport_export\\\\icons\\\\camwheel_panel_30.png\" to \"$scripts\\\\3dsmax_camwheel_viewport_export\\\\icons\""
    assert_includes recipe, "copy \"startup\\\\CamWheel_ViewportExport_Startup.ms\" to \"$startupScripts\""
    assert_includes recipe, "drop \"install.ms\""
    assert_includes recipe, "clear temp on MAX exit"
  end

  def test_mzp_drop_script_loads_installed_main_script_and_reports_result
    script = File.read(package_file("install.ms"))

    refute_match(/\Alocal\s+/m, script)
    assert_includes script, "getDir #scripts"
    assert_includes script, "3dsmax_camwheel_viewport_export"
    assert_includes script, "CamWheel_ViewportExport.ms"
    assert_includes script, "fn CamWheel_RunMzpInstall"
    assert_includes script, "fileIn"
    assert_includes script, "messageBox"
  end

  def test_startup_loader_bootstraps_main_script_from_scripts_directory
    script = File.read(package_file("CamWheel_ViewportExport_Startup.ms"))

    refute_match(/\Alocal\s+/m, script)
    assert_includes script, "getDir #scripts"
    assert_includes script, "3dsmax_camwheel_viewport_export"
    assert_includes script, "CamWheel_ViewportExport.ms"
    assert_includes script, "doesFileExist"
    assert_includes script, "fn CamWheel_LoadInstalledStartupScript"
    assert_includes script, "fileIn"
  end

  private

  def entry_file(name)
    File.expand_path("../../external/3dsmax_camwheel_viewport_export/#{name}", __dir__)
  end

  def package_file(name)
    File.expand_path("../../external/3dsmax_camwheel_viewport_export/mzp/#{name}", __dir__)
  end
end
