require_relative "../test_helper"

align_view_tool_file = File.expand_path("../../cam_wheel/tools/align_view_tool.rb", __dir__)
require align_view_tool_file if File.exist?(align_view_tool_file)

unless defined?(Geom)
  module Geom
    class Point3d
      attr_reader :x, :y, :z

      def initialize(x, y, z)
        @x = x
        @y = y
        @z = z
      end
    end
  end
end

unless defined?(Sketchup)
  module ::Sketchup
    class Color
      def initialize(*_args); end
    end
  end
end

unless defined?(GL_POLYGON)
  GL_POLYGON = :gl_polygon
end

unless defined?(GL_LINE_STRIP)
  GL_LINE_STRIP = :gl_line_strip
end

unless defined?(GL_LINES)
  GL_LINES = :gl_lines
end

class CamWheelAlignViewToolTest < Minitest::Test
  FakeView = Struct.new(:draw_calls, :line_width, :drawing_color) do
    def draw2d(mode, points)
      draw_calls << [mode, points]
    end
  end

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

  def test_draw_fills_preview_face_before_outline
    tool = CamWheel::Tools::AlignViewTool.new
    tool.instance_variable_set(:@preview, {
                                 polygon: [[10, 10], [30, 10], [30, 20], [10, 20]],
                                 screen: [20, 15]
                               })
    view = FakeView.new([])

    tool.draw(view)

    assert_equal GL_POLYGON, view.draw_calls[0][0]
    assert_equal GL_LINE_STRIP, view.draw_calls[1][0]
  end
end
