# frozen_string_literal: true

module CamWheel
  module Services
    class ExportService
      PRESET_LONG_EDGE = {
        "1k" => 1920,
        "2k" => 2560,
        "4k" => 3840
      }.freeze

      class << self
        def dimensions_for(preset:, ratio_width:, ratio_height:)
          long_edge = PRESET_LONG_EDGE.fetch(preset.downcase)
          ratio = ratio_width.to_f / ratio_height.to_f

          if ratio >= 1.0
            width = long_edge
            height = (width / ratio).round
          else
            height = long_edge
            width = (height * ratio).round
          end

          [width, height]
        end

        def export_current_view(view:, ratio_width:, ratio_height:, preset:, hide_overlay:)
          return false unless defined?(Sketchup) && defined?(UI)

          path = UI.savepanel("导出构图图片", nil, "camwheel-#{preset}.png")
          return false unless path

          width, height = dimensions_for(preset: preset, ratio_width: ratio_width, ratio_height: ratio_height)
          camera = view.camera
          original_aspect = camera.respond_to?(:aspect_ratio) ? camera.aspect_ratio : nil
          restore_aspect = camera.respond_to?(:aspect_ratio=)

          begin
            hide_overlay.call(true)
            camera.aspect_ratio = ratio_width.to_f / ratio_height.to_f if restore_aspect
            view.invalidate
            view.write_image(
              filename: path,
              width: width,
              height: height,
              antialias: true,
              compression: 0.9
            )
          ensure
            camera.aspect_ratio = original_aspect if restore_aspect && !original_aspect.nil?
            hide_overlay.call(false)
            view.invalidate
          end

          true
        end
      end
    end
  end
end
