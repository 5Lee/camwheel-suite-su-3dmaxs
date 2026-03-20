# frozen_string_literal: true

constants_file = File.join(__dir__, "constants")
composition_tool_file = File.join(__dir__, "tools", "composition_overlay_tool")
penetration_tool_file = File.join(__dir__, "tools", "penetration_tool")
align_view_tool_file = File.join(__dir__, "tools", "align_view_tool")
settings_dialog_file = File.join(__dir__, "ui", "settings_dialog")

if defined?(Sketchup)
  Sketchup.require(constants_file)
  Sketchup.require(composition_tool_file)
  Sketchup.require(penetration_tool_file)
  Sketchup.require(align_view_tool_file)
  Sketchup.require(settings_dialog_file)
else
  require constants_file
  require composition_tool_file
  require penetration_tool_file
  require align_view_tool_file
  require settings_dialog_file
end

module CamWheel
  class << self
    def boot
      return if defined?(@booted) && @booted

      @booted = true
      return unless defined?(::UI) && defined?(Sketchup)

      build_toolbar
      build_menu
    end

    def toggle_composition_overlay
      model = Sketchup.active_model
      view = model.active_view

      if composition_overlay_tool.active?
        model.select_tool(nil)
        composition_overlay_tool.deactivate(view)
      else
        model.select_tool(composition_overlay_tool)
      end
    end

    def show_settings
      UI::SettingsDialog.show
    end

    private

    def build_toolbar
      toolbar = ::UI::Toolbar.new(PLUGIN_NAME)
      toolbar.add_item(penetration_command)
      toolbar.add_item(align_view_command)
      toolbar.add_item(composition_overlay_command)
      toolbar.add_item(settings_command)
      toolbar.restore
    end

    def build_menu
      extensions_menu = ::UI.menu("Extensions")
      submenu = extensions_menu.add_submenu(PLUGIN_NAME)
      submenu.add_item(penetration_command)
      submenu.add_item(align_view_command)
      submenu.add_item(composition_overlay_command)
      submenu.add_item(settings_command)
    end

    def penetration_command
      @penetration_command ||= begin
        command = ::UI::Command.new("物体穿透") { Sketchup.active_model.select_tool(Tools::PenetrationTool.new) }
        command.menu_text = "物体穿透"
        command.tooltip = "物体穿透"
        command.status_bar_text = "沿当前视线穿过前方第一个遮挡物"
        apply_command_icons(command, "penetration.svg")
        command
      end
    end

    def align_view_command
      @align_view_command ||= begin
        command = ::UI::Command.new("视角对齐") { Sketchup.active_model.select_tool(Tools::AlignViewTool.new) }
        command.menu_text = "视角对齐"
        command.tooltip = "视角对齐"
        command.status_bar_text = "点击一个可见面以对齐当前视角"
        apply_command_icons(command, "align_view.svg")
        command
      end
    end

    def composition_overlay_command
      @composition_overlay_command ||= begin
        command = ::UI::Command.new("构图辅助") { toggle_composition_overlay }
        command.menu_text = "构图辅助"
        command.tooltip = "构图辅助"
        command.status_bar_text = "切换 CamWheel 构图辅助"
        apply_command_icons(command, "composition.svg")
        command
      end
    end

    def settings_command
      @settings_command ||= begin
        command = ::UI::Command.new("设置") { show_settings }
        command.menu_text = "设置"
        command.tooltip = "设置"
        command.status_bar_text = "打开 CamWheel 设置"
        apply_command_icons(command, "settings.svg")
        command
      end
    end

    def composition_overlay_tool
      @composition_overlay_tool ||= Tools::CompositionOverlayTool.new
    end

    def apply_command_icons(command, file_name)
      icon_path = File.join(__dir__, "assets", "icons", file_name)
      return command unless File.exist?(icon_path)

      command.small_icon = icon_path
      command.large_icon = icon_path
      command
    end
  end
end

CamWheel.boot
