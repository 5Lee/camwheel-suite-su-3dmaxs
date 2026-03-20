require_relative "../test_helper"

align_view_tool_file = File.expand_path("../../cam_wheel/tools/align_view_tool.rb", __dir__)
require align_view_tool_file if File.exist?(align_view_tool_file)

class CamWheelAlignViewToolTest < Minitest::Test
  def test_preview_marker_points_form_screen_square
    points = CamWheel::Tools::AlignViewTool.preview_marker_points(
      screen_x: 100,
      screen_y: 60,
      size: 12
    )

    assert_equal 4, points.length
    assert_equal [94, 54], points[0]
    assert_equal [106, 66], points[2]
  end
end
