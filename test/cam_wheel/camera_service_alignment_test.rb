require_relative "../test_helper"

camera_service_file = File.expand_path("../../cam_wheel/services/camera_service.rb", __dir__)
require camera_service_file if File.exist?(camera_service_file)

unless defined?(Sketchup)
  module ::Sketchup
  end
end

unless defined?(UI)
  module ::UI
  end
end

class CamWheelCameraServiceAlignmentTest < Minitest::Test
  FakePerspectiveView = Struct.new(:camera)

  FakeAssignableView = Struct.new(:camera, :assigned_camera) do
    attr_reader :invalidated

    def camera=(value)
      self[:assigned_camera] = value
      self[:camera] = value
    end

    def invalidate
      @invalidated = true
    end
  end

  class FakePerspectiveCamera
    attr_reader :perspective_enabled

    def perspective=(value)
      @perspective_enabled = value
    end

    def respond_to?(*)
      raise "should not query camera respond_to?"
    end
  end

  class FakeTwoPointCamera
    attr_reader :fov

    def initialize(fov: 42.0)
      @fov = fov
    end

    def is_2d?
      true
    end
  end

  def setup
    ::Sketchup.instance_variable_set(:@camwheel_test_last_action, nil)
  end

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

  def test_enable_two_point_perspective_does_not_query_camera_respond_to
    ::Sketchup.singleton_class.send(:define_method, :send_action) do |action|
      @camwheel_test_last_action = action
    end

    camera = FakePerspectiveCamera.new
    view = FakePerspectiveView.new(camera)

    CamWheel::Services::CameraService.send(:enable_two_point_perspective!, view)

    assert_equal true, camera.perspective_enabled
  end

  def test_enable_two_point_perspective_defers_send_action_on_macos
    timer_blocks = []

    ::Sketchup.singleton_class.send(:define_method, :platform) { :platform_osx }
    ::Sketchup.singleton_class.send(:define_method, :send_action) do |action|
      @camwheel_test_last_action = action
    end
    ::UI.singleton_class.send(:define_method, :start_timer) do |_seconds, _repeat = false, &block|
      timer_blocks << block
      timer_blocks.length
    end

    camera = FakePerspectiveCamera.new
    view = FakePerspectiveView.new(camera)

    CamWheel::Services::CameraService.send(:enable_two_point_perspective!, view)

    assert_equal true, camera.perspective_enabled
    assert_equal 1, timer_blocks.length
    assert_nil ::Sketchup.instance_variable_get(:@camwheel_test_last_action)

    timer_blocks.first.call

    assert_equal "viewTwoPointPerspective:", ::Sketchup.instance_variable_get(:@camwheel_test_last_action)
  end

  def test_apply_camera_replaces_two_point_perspective_camera_with_standard_camera
    unless defined?(::Sketchup::Camera)
      ::Sketchup.const_set(:Camera, Class.new do
        attr_reader :eye, :target, :up, :perspective, :fov

        def initialize(eye, target, up, perspective = true, fov = 30.0)
          @eye = eye
          @target = target
          @up = up
          @perspective = perspective
          @fov = fov
        end
      end)
    end

    view = FakeAssignableView.new(FakeTwoPointCamera.new)

    CamWheel::Services::CameraService.send(:apply_camera, view: view, eye: :new_eye, target: :new_target, up: :new_up)

    refute_nil view.assigned_camera
    assert_equal :new_eye, view.assigned_camera.eye
    assert_equal :new_target, view.assigned_camera.target
    assert_equal :new_up, view.assigned_camera.up
    assert_equal true, view.assigned_camera.perspective
    assert_equal 42.0, view.assigned_camera.fov
    assert_equal true, view.invalidated
  end
end
