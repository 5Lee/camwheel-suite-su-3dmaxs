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

  def test_view_direction_preserves_current_view_side
    direction = CamWheel::Services::CameraService.view_direction_for_normal(
      normal: [0.0, 0.0, 1.0],
      current_direction: [0.0, 0.0, 1.0]
    )

    assert_equal [0.0, 0.0, 1.0], direction
  end

  def test_alignment_distance_uses_eye_to_hit_point
    distance = CamWheel::Services::CameraService.alignment_distance(
      eye: [0.0, 0.0, 100.0],
      point: [0.0, 0.0, 0.0]
    )

    assert_equal 100.0, distance
  end
end
