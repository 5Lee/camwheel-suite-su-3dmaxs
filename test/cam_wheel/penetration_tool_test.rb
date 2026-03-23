require_relative "../test_helper"

penetration_tool_file = File.expand_path("../../cam_wheel/tools/penetration_tool.rb", __dir__)
require penetration_tool_file if File.exist?(penetration_tool_file)

unless defined?(Sketchup)
  module ::Sketchup
  end
end

class CamWheelPenetrationToolTest < Minitest::Test
  FakeView = Struct.new(:invalidated)

  class FakeModel
    attr_reader :active_view

    def initialize(view)
      @active_view = view
    end
  end

  def setup
    @original_penetrate = CamWheel::Services::CameraService.method(:penetrate_active_view)
    @original_read = CamWheel::Data::SettingsStore.method(:read)

    CamWheel::Services::CameraService.singleton_class.send(:define_method, :penetrate_active_view) do |view:, safety_offset:|
      view.invalidated = safety_offset
      42.0
    end

    CamWheel::Data::SettingsStore.singleton_class.send(:define_method, :read) do |key|
      key == :penetration_offset ? 123.0 : nil
    end

    ::Sketchup.singleton_class.send(:define_method, :status_text=) do |value|
      @camwheel_test_status_text = value
    end
  end

  def teardown
    CamWheel::Services::CameraService.singleton_class.send(:define_method, :penetrate_active_view, @original_penetrate)
    CamWheel::Data::SettingsStore.singleton_class.send(:define_method, :read, @original_read)
  end

  def test_run_executes_without_requiring_tool_switch
    view = FakeView.new(false)
    model = FakeModel.new(view)

    result = CamWheel::Tools::PenetrationTool.run(model: model)

    assert_equal :moved, result
    assert_equal 123.0, view.invalidated
  end

  def test_run_reports_no_hit_without_moving_camera
    CamWheel::Services::CameraService.singleton_class.send(:define_method, :penetrate_active_view) do |view:, safety_offset:|
      view.invalidated = safety_offset
      nil
    end

    view = FakeView.new(false)
    model = FakeModel.new(view)

    result = CamWheel::Tools::PenetrationTool.run(model: model)

    assert_equal :no_hit, result
    assert_equal 123.0, view.invalidated
    assert_equal "CamWheel 前方中心没有物体", ::Sketchup.instance_variable_get(:@camwheel_test_status_text)
  end

  def test_on_set_cursor_defers_to_sketchup_default_cursor
    tool = CamWheel::Tools::PenetrationTool.new

    assert_equal false, tool.onSetCursor
  end
end
