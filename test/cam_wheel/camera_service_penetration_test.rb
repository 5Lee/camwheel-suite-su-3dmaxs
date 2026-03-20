require_relative "../test_helper"

camera_service_file = File.expand_path("../../cam_wheel/services/camera_service.rb", __dir__)
require camera_service_file if File.exist?(camera_service_file)

class CamWheelCameraServicePenetrationTest < Minitest::Test
  def test_exit_distance_moves_beyond_first_solid
    spans = [[10.0, 20.0]]
    final_distance = CamWheel::Services::CameraService.exit_distance(
      spans: spans,
      safety_offset: 5.0
    )

    assert_equal 25.0, final_distance
  end

  def test_ray_box_exit_distance_returns_farthest_hit
    distance = CamWheel::Services::CameraService.ray_box_exit_distance(
      origin: [0.0, 0.0, 0.0],
      direction: [1.0, 0.0, 0.0],
      min_corner: [10.0, -2.0, -2.0],
      max_corner: [20.0, 2.0, 2.0]
    )

    assert_equal 20.0, distance
  end

  def test_first_object_exit_distance_stops_at_first_object_boundary
    probe_hits = {
      11.0 => { id: :wall, distance: 20.0 },
      21.0 => { id: :chair, distance: 35.0 }
    }

    distance = CamWheel::Services::CameraService.first_object_exit_distance(
      entry_distance: 10.0,
      blocker_id: :wall,
      sample_step: 1.0,
      max_distance: 50.0
    ) do |probe_distance|
      probe_hits[probe_distance]
    end

    assert_equal 20.0, distance
  end
end
