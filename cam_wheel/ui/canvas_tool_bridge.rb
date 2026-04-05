# frozen_string_literal: true

module CamWheel
  module UI
    module CanvasToolBridge
      class << self
        def bind(dialog)
          dialog.add_action_callback("canvasToolPickImages") do |_action_context|
            pick_images
          end

          dialog.add_action_callback("canvasToolSaveExport") do |_action_context, suggested_name|
            save_export(suggested_name)
          end
        end

        private

        def pick_images
          return [] unless defined?(::UI) && ::UI.respond_to?(:openpanel)

          result = ::UI.openpanel("选择图片", nil, "", true)
          Array(result).compact
        rescue StandardError
          []
        end

        def save_export(suggested_name)
          return nil unless defined?(::UI) && ::UI.respond_to?(:savepanel)

          ::UI.savepanel("导出拼图", nil, normalize_filename(suggested_name))
        rescue StandardError
          nil
        end

        def normalize_filename(name)
          value = name.to_s.strip
          return "collage-export.jpg" if value.empty?

          value
        end
      end
    end
  end
end
