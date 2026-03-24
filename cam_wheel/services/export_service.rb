# frozen_string_literal: true

require "tempfile"

composition_service_file = File.join(__dir__, "composition_service")

if defined?(Sketchup) && Sketchup.respond_to?(:require)
  Sketchup.require(composition_service_file)
else
  require composition_service_file
end

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
          return false unless defined?(Sketchup) && defined?(::UI)

          path = ::UI.savepanel(
            "导出构图图片",
            nil,
            default_filename(model_path: current_model_path, exported_at: Time.now)
          )
          return false unless path

          width, height = dimensions_for(
            preset: preset,
            ratio_width: ratio_width,
            ratio_height: ratio_height
          )
          frame = Services::CompositionService.fit_frame(
            viewport_width: view.vpwidth,
            viewport_height: view.vpheight,
            ratio_width: ratio_width,
            ratio_height: ratio_height
          )
          capture_width, capture_height = capture_dimensions(
            viewport_width: view.vpwidth,
            viewport_height: view.vpheight,
            frame: frame,
            output_width: width,
            output_height: height
          )
          temp_file = Tempfile.new(["camwheel-export-", ".jpg"])
          temp_path = temp_file.path
          temp_file.close

          begin
            hide_overlay.call(true)
            view.invalidate
            captured = view.write_image(
              filename: temp_path,
              width: capture_width,
              height: capture_height,
              antialias: true,
              compression: 0.9
            )
            return false unless captured

            crop_and_save(
              source_path: temp_path,
              output_path: path,
              frame: frame,
              viewport_width: view.vpwidth,
              viewport_height: view.vpheight,
              output_width: width,
              output_height: height
            )
          ensure
            hide_overlay.call(false)
            view.invalidate
            File.delete(temp_path) if File.exist?(temp_path)
          end

          true
        end

        private

        def default_filename(model_path:, exported_at:)
          base_name = model_basename(model_path)
          timestamp = exported_at.strftime("%Y%m%d-%H%M%S")
          "#{base_name}-#{timestamp}.jpg"
        end

        def model_basename(model_path)
          path = model_path.to_s.strip
          return "camwheel" if path.empty?

          basename = File.basename(path, File.extname(path)).strip
          basename.empty? ? "camwheel" : basename
        end

        def current_model_path
          return "" unless defined?(Sketchup) && Sketchup.respond_to?(:active_model)

          model = Sketchup.active_model
          return "" unless model && model.respond_to?(:path)

          model.path
        rescue StandardError
          ""
        end

        def capture_dimensions(viewport_width:, viewport_height:, frame:, output_width:, output_height:)
          scale_x = output_width.to_f / frame.width.to_f
          scale_y = output_height.to_f / frame.height.to_f

          [
            [(viewport_width * scale_x).ceil, output_width].max,
            [(viewport_height * scale_y).ceil, output_height].max
          ]
        end

        def crop_and_save(source_path:, output_path:, frame:, viewport_width:, viewport_height:, output_width:, output_height:)
          image_rep = image_rep_class.new
          image_rep.load_file(source_path)

          crop_x, crop_y, crop_width, crop_height = scaled_crop_rect(
            image_width: image_rep.width,
            image_height: image_rep.height,
            viewport_width: viewport_width,
            viewport_height: viewport_height,
            frame: frame
          )

          cropped_image = resample_region(
            image_rep: image_rep,
            crop_x: crop_x,
            crop_y: crop_y,
            crop_width: crop_width,
            crop_height: crop_height,
            output_width: output_width,
            output_height: output_height
          )
          cropped_image.save_file(output_path)
        end

        def scaled_crop_rect(image_width:, image_height:, viewport_width:, viewport_height:, frame:)
          crop_x = ((frame.x.to_f * image_width) / viewport_width).round
          crop_y = ((frame.y.to_f * image_height) / viewport_height).round
          crop_width = [((frame.width.to_f * image_width) / viewport_width).round, 1].max
          crop_height = [((frame.height.to_f * image_height) / viewport_height).round, 1].max

          crop_x = [[crop_x, 0].max, image_width - 1].min
          crop_y = [[crop_y, 0].max, image_height - 1].min
          crop_width = [crop_width, image_width - crop_x].min
          crop_height = [crop_height, image_height - crop_y].min

          [crop_x, crop_y, crop_width, crop_height]
        end

        def resample_region(image_rep:, crop_x:, crop_y:, crop_width:, crop_height:, output_width:, output_height:)
          bytes_per_pixel = image_rep.bits_per_pixel.to_i / 8
          row_stride = (image_rep.width * bytes_per_pixel) + image_rep.row_padding.to_i
          source_data = image_rep.data
          output_data = +"".b

          output_height.times do |target_y|
            source_y = crop_y + (((target_y + 0.5) * crop_height) / output_height).floor
            source_y = [[source_y, crop_y].max, crop_y + crop_height - 1].min
            row_offset = source_y * row_stride

            output_width.times do |target_x|
              source_x = crop_x + (((target_x + 0.5) * crop_width) / output_width).floor
              source_x = [[source_x, crop_x].max, crop_x + crop_width - 1].min
              pixel_offset = row_offset + (source_x * bytes_per_pixel)
              output_data << source_data.byteslice(pixel_offset, bytes_per_pixel)
            end
          end

          image_rep_class.new.set_data(output_width, output_height, image_rep.bits_per_pixel, 0, output_data)
        end

        def image_rep_class
          ::Sketchup::ImageRep
        end
      end
    end
  end
end
