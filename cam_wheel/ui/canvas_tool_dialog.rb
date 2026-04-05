# frozen_string_literal: true

canvas_tool_bridge_file = File.join(__dir__, "canvas_tool_bridge")

if defined?(Sketchup)
  Sketchup.require(canvas_tool_bridge_file)
else
  require canvas_tool_bridge_file
end

module CamWheel
  module UI
    class CanvasToolDialog
      DIALOG_ID = "camwheel-canvas-tool".freeze

      class << self
        def show
          current_dialog = dialog
          current_dialog.show
          current_dialog.bring_to_front if current_dialog.respond_to?(:bring_to_front)
        end

        private

        def dialog
          @dialog ||= build_dialog
        end

        def build_dialog
          dialog = ::UI::HtmlDialog.new(
            dialog_title: "CamWheel 拼图画布",
            preferences_key: DIALOG_ID,
            scrollable: true,
            resizable: true,
            width: 1280,
            height: 860,
            style: ::UI::HtmlDialog::STYLE_DIALOG
          )
          dialog.set_file(File.join(__dir__, "..", "web_canvas_tool", "index.html"))
          CanvasToolBridge.bind(dialog)
          dialog.set_on_closed { @dialog = nil } if dialog.respond_to?(:set_on_closed)
          dialog
        end
      end
    end
  end
end
