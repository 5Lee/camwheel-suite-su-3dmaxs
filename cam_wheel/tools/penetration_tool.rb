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
    class PenetrationTool
      class << self
        def run(model: Sketchup.active_model)
          return :no_model unless model

          view = model.active_view
          moved_distance = Services::CameraService.penetrate_active_view(
            view: view,
            safety_offset: Data::SettingsStore.read(:penetration_offset)
          )

          Sketchup.status_text =
            if moved_distance
              "CamWheel 物体穿透完成"
            else
              "CamWheel 未检测到可穿透物体"
            end

          moved_distance ? :moved : :no_hit
        end
      end

      def activate
        model = Sketchup.active_model
        view = model.active_view
        self.class.run(model: model)
        view.invalidate if view.respond_to?(:invalidate)
      end
    end
  end
end
