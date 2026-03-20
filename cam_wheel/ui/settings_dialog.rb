# frozen_string_literal: true

ui_bridge_file = File.join(__dir__, "ui_bridge")

if defined?(Sketchup)
  Sketchup.require(ui_bridge_file)
else
  require ui_bridge_file
end

module CamWheel
  module UI
    class SettingsDialog
      DIALOG_ID = "camwheel-settings".freeze

      class << self
        def show
          dialog.show
          dialog.bring_to_front if dialog.respond_to?(:bring_to_front)
        end

        private

        def dialog
          @dialog ||= build_dialog
        end

        def build_dialog
          dialog = HtmlDialog.new(
            dialog_title: "CamWheel 设置",
            preferences_key: DIALOG_ID,
            scrollable: true,
            resizable: true,
            width: 540,
            height: 760,
            style: HtmlDialog::STYLE_DIALOG
          )
          dialog.set_file(File.join(__dir__, "..", "assets", "settings.html"))
          UiBridge.bind(dialog)
          dialog
        end
      end
    end
  end
end
