require_relative "../test_helper"

unless defined?(Sketchup)
  module ::Sketchup
  end
end

export_service_file = File.expand_path("../../cam_wheel/services/export_service.rb", __dir__)
require export_service_file if File.exist?(export_service_file)

module ::UI
  class << self
    attr_accessor :camwheel_test_saved_paths
  end

  def self.savepanel(*_args)
    self.camwheel_test_saved_paths ||= []
    path = "/tmp/camwheel-test.png"
    self.camwheel_test_saved_paths << path
    path
  end
end

class CamWheelExportServiceUiResolutionTest < Minitest::Test
  FakeCamera = Struct.new(:aspect_ratio) do
    def aspect_ratio=(value)
      self[:aspect_ratio] = value
    end
  end

  FakeView = Struct.new(:camera, :writes) do
    def invalidate; end

    def write_image(options)
      writes << options
    end
  end

  def test_export_uses_top_level_ui_savepanel
    camera = FakeCamera.new(nil)
    view = FakeView.new(camera, [])

    result = CamWheel::Services::ExportService.export_current_view(
      view: view,
      ratio_width: 4.0,
      ratio_height: 3.0,
      preset: "1k",
      hide_overlay: ->(_value) {}
    )

    assert_equal true, result
    assert_equal "/tmp/camwheel-test.png", ::UI.camwheel_test_saved_paths.last
    assert_equal "/tmp/camwheel-test.png", view.writes.last[:filename]
  end
end
