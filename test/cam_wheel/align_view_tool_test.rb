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

    class Transformation
      def *(other)
        other
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

unless defined?(UI)
  module ::UI
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
    attr_reader :invalidated

    def draw2d(mode, points)
      draw_calls << [mode, points]
    end

    def invalidate
      @invalidated = true
    end
  end

  FakeModel = Struct.new(:selected_tools) do
    def select_tool(tool)
      selected_tools << tool
    end
  end

  class BrokenPathEntity
    def respond_to?(*)
      raise "should not query entity respond_to?"
    end
  end

  class FakeNormal
    attr_reader :transformation

    def transform(transformation)
      @transformation = transformation
      :transformed
    end
  end

  def setup
    @timer_blocks = []
    @align_view_calls = []
    ::Sketchup.instance_variable_set(:@camwheel_test_model, nil)

    ::Sketchup.singleton_class.send(:define_method, :active_model) do
      @camwheel_test_model ||= CamWheelAlignViewToolTest::FakeModel.new([])
    end
    ::UI.singleton_class.send(:define_method, :start_timer) do |_seconds, _repeat = false, &block|
      @camwheel_test_timer_blocks ||= []
      @camwheel_test_timer_blocks << block
      @camwheel_test_timer_blocks.length
    end
    ::UI.instance_variable_set(:@camwheel_test_timer_blocks, @timer_blocks)
    align_view_calls = @align_view_calls
    CamWheel::Services::CameraService.singleton_class.send(:define_method, :align_view) do |**kwargs|
      align_view_calls << kwargs
      true
    end
    CamWheel::Data::SettingsStore.singleton_class.send(:define_method, :read) do |_key|
      true
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

  def test_on_set_cursor_defers_to_sketchup_default_cursor
    tool = CamWheel::Tools::AlignViewTool.new

    assert_equal false, tool.onSetCursor
  end

  def test_transformed_normal_uses_instance_path_transformation_without_querying_entities
    unless defined?(::Sketchup::InstancePath)
      ::Sketchup.const_set(:InstancePath, Class.new do
        def initialize(path)
          @path = path
        end

        def transformation
          :instance_path_transform
        end
      end)
    end

    tool = CamWheel::Tools::AlignViewTool.new
    normal = FakeNormal.new

    result = tool.send(:transformed_normal, normal, [BrokenPathEntity.new, Object.new])

    assert_equal :transformed, result
    assert_equal :instance_path_transform, normal.transformation
  end

  def test_on_left_button_down_defers_tool_deselection_until_after_callback
    tool = CamWheel::Tools::AlignViewTool.new
    view = FakeView.new([])
    preview = { point: :picked_point, normal: :picked_normal, polygon: [], screen: [0, 0] }
    tool.define_singleton_method(:pick_preview) do |_view, _x, _y|
      preview
    end

    tool.onLButtonDown(0, 10, 20, view)

    assert_equal [], ::Sketchup.active_model.selected_tools
    assert_equal 1, @timer_blocks.length
    assert_equal true, view.invalidated

    @timer_blocks.first.call

    assert_equal [nil], ::Sketchup.active_model.selected_tools
  end

  def test_on_left_button_down_only_defers_tool_exit_without_two_point_perspective
    tool = CamWheel::Tools::AlignViewTool.new
    view = FakeView.new([])
    preview = { point: :picked_point, normal: :picked_normal, polygon: [], screen: [0, 0] }
    tool.define_singleton_method(:pick_preview) do |_view, _x, _y|
      preview
    end

    tool.onLButtonDown(0, 10, 20, view)

    refute_includes @align_view_calls.last.keys, :enable_two_point_perspective
    assert_equal [], ::Sketchup.active_model.selected_tools
    assert_equal 1, @timer_blocks.length

    @timer_blocks.first.call

    assert_equal [nil], ::Sketchup.active_model.selected_tools
  end
end
