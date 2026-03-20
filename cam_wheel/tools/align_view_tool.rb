# frozen_string_literal: true

camera_service_file = File.join(__dir__, "..", "services", "camera_service")
settings_store_file = File.join(__dir__, "..", "data", "settings_store")

if defined?(Sketchup)
  Sketchup.require(camera_service_file)
  Sketchup.require(settings_store_file)
else
  require camera_service_file
  require settings_store_file
end

module CamWheel
  module Tools
    class AlignViewTool
      def activate
        Sketchup.status_text = "CamWheel 视角对齐：点击一个可见面"
      end

      def onLButtonDown(_flags, x, y, view)
        hit = view.model.raytest(view.pickray(x, y), false)
        return unless hit

        point, path = hit
        face = path.last if path.last.is_a?(Sketchup::Face)
        return unless face

        Services::CameraService.align_view(
          view: view,
          point: point,
          normal: transformed_normal(face.normal, path),
          enable_two_point_perspective: Data::SettingsStore.read(:align_enable_two_point_perspective)
        )

        Sketchup.active_model.select_tool(nil)
      end

      private

      def transformed_normal(normal, path)
        transformation = path[0...-1].reduce(Geom::Transformation.new) do |memo, entity|
          entity.respond_to?(:transformation) ? memo * entity.transformation : memo
        end

        normal.transform(transformation)
      end
    end
  end
end
