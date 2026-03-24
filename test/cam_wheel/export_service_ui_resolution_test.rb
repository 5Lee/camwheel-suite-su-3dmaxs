require_relative "../test_helper"
require "fileutils"

unless defined?(Sketchup)
  module ::Sketchup
    def self.require(path)
      Kernel.require(path)
    end
  end
end

export_service_file = File.expand_path("../../cam_wheel/services/export_service.rb", __dir__)
require export_service_file if File.exist?(export_service_file)

module ::UI
  class << self
    attr_accessor :camwheel_test_saved_paths
    attr_accessor :camwheel_test_savepanel_calls
  end

  def self.savepanel(*args)
    self.camwheel_test_saved_paths ||= []
    self.camwheel_test_savepanel_calls ||= []
    path = "/tmp/camwheel-test.jpg"
    self.camwheel_test_savepanel_calls << args
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

  class ::Sketchup::ImageRep
    class << self
      attr_accessor :camwheel_test_images, :camwheel_test_saved_images
    end

    attr_reader :width, :height, :bits_per_pixel, :row_padding

    def load_file(path)
      payload = self.class.camwheel_test_images.fetch(path)
      @width = payload[:width]
      @height = payload[:height]
      @bits_per_pixel = payload[:bits_per_pixel]
      @row_padding = payload[:row_padding]
      @data = payload[:data]
    end

    def data
      @data
    end

    def set_data(width, height, bits_per_pixel, row_padding, pixel_data)
      @width = width
      @height = height
      @bits_per_pixel = bits_per_pixel
      @row_padding = row_padding
      @data = pixel_data
      self
    end

    def save_file(path)
      self.class.camwheel_test_saved_images ||= {}
      self.class.camwheel_test_saved_images[path] = {
        width: width,
        height: height,
        bits_per_pixel: bits_per_pixel,
        row_padding: row_padding,
        data: data
      }
    end
  end

  FakeView = Struct.new(:camera, :writes, :vpwidth, :vpheight) do
    def invalidate; end

    def write_image(options)
      writes << options
      File.binwrite(options[:filename], "camwheel")
      data = +"".b

      options[:height].times do |y|
        options[:width].times do |x|
          data << [x % 256, y % 256, 0].pack("C*")
        end
      end

      ::Sketchup::ImageRep.camwheel_test_images ||= {}
      ::Sketchup::ImageRep.camwheel_test_images[options[:filename]] = {
        width: options[:width],
        height: options[:height],
        bits_per_pixel: 24,
        row_padding: 0,
        data: data
      }
    end
  end

  FakeModel = Struct.new(:path)

  def setup
    ::Sketchup::ImageRep.camwheel_test_images = {}
    ::Sketchup::ImageRep.camwheel_test_saved_images = {}
    ::UI.camwheel_test_saved_paths = []
    ::UI.camwheel_test_savepanel_calls = []
    ::Sketchup.singleton_class.send(:define_method, :active_model) { FakeModel.new("/tmp/example-model.skp") }
  end

  def test_export_uses_top_level_ui_savepanel
    camera = FakeCamera.new(0.0)
    view = FakeView.new(camera, [], 400, 300)

    result = CamWheel::Services::ExportService.export_current_view(
      view: view,
      ratio_width: 4.0,
      ratio_height: 3.0,
      preset: "1k",
      hide_overlay: ->(_value) {}
    )

    assert_equal true, result
    assert_equal "/tmp/camwheel-test.jpg", ::UI.camwheel_test_saved_paths.last
    assert_match(/\Aexample-model-\d{8}-\d{6}\.jpg\z/, ::UI.camwheel_test_savepanel_calls.last[2])
    assert_match(/\.jpg\z/, view.writes.last[:filename])
    assert_equal 1920, view.writes.last[:width]
    assert_equal 1440, view.writes.last[:height]
    assert_equal 1920, ::Sketchup::ImageRep.camwheel_test_saved_images.fetch("/tmp/camwheel-test.jpg")[:width]
  end

  def test_export_keeps_original_camera_state_and_crops_to_composition_frame
    camera = FakeCamera.new(0.0)
    view = FakeView.new(camera, [], 400, 300)

    CamWheel::Services::ExportService.export_current_view(
      view: view,
      ratio_width: 1.0,
      ratio_height: 1.0,
      preset: "1k",
      hide_overlay: ->(_value) {}
    )

    saved = ::Sketchup::ImageRep.camwheel_test_saved_images.fetch("/tmp/camwheel-test.jpg")
    first_pixel = saved[:data].bytes.first(3)
    last_pixel_offset = ((saved[:width] * saved[:height]) - 1) * 3
    last_pixel = saved[:data].byteslice(last_pixel_offset, 3).bytes

    assert_equal camera, view.camera
    assert_equal 0.0, camera.aspect_ratio
    assert_equal 1920, saved[:width]
    assert_equal 1920, saved[:height]
    assert_equal [64, 0, 0], first_pixel
    assert_equal [191, 127, 0], last_pixel
  end
end
