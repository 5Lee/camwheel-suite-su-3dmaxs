require_relative "../test_helper"

camera_service_file = File.expand_path("../../cam_wheel/services/camera_service.rb", __dir__)
require camera_service_file if File.exist?(camera_service_file)

class CamWheelCameraServiceAlignmentTest < Minitest::Test
  def test_view_direction_for_normal_points_back_along_face_normal
    direction = CamWheel::Services::CameraService.view_direction_for_normal(
      normal: [0.0, 0.0, 1.0]
    )

    assert_equal [0.0, 0.0, -1.0], direction
  end
end
