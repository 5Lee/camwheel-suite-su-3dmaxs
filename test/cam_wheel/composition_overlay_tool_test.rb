require_relative "../test_helper"

composition_overlay_tool_file = File.expand_path("../../cam_wheel/tools/composition_overlay_tool.rb", __dir__)
require composition_overlay_tool_file if File.exist?(composition_overlay_tool_file)

unless defined?(VK_CONTROL)
  VK_CONTROL = 17
end

unless defined?(VK_ALT)
  VK_ALT = 18
end

unless defined?(Sketchup)
  module ::Sketchup
  end
end

unless defined?(UI)
  module ::UI
  end
end

class CamWheelCompositionOverlayToolTest < Minitest::Test
  MenuItem = Struct.new(:label, :block)

  class FakeMenu
    attr_reader :items, :label

    def initialize(label = nil)
      @label = label
      @items = []
    end

    def add_item(label, &block)
      @items << MenuItem.new(label, block)
      label
    end

    def add_submenu(label)
      submenu = self.class.new(label)
      @items << submenu
      submenu
    end

    def add_separator
      @items << :separator
    end
  end

  FakeCamera = Struct.new(:focal_length_value, :perspective_value, :fov_value) do
    def focal_length
      focal_length_value
    end

    def focal_length=(value)
      self.focal_length_value = value
    end

    def fov
      fov_value
    end

    def fov=(value)
      self.fov_value = value
    end

    def perspective=(value)
      self.perspective_value = value
    end
  end

  class FakeView
    attr_accessor :camera, :invalidated, :vpwidth, :vpheight

    def initialize(camera, invalidated = false, vpwidth = 400, vpheight = 300)
      @camera = camera
      @invalidated = invalidated
      @vpwidth = vpwidth
      @vpheight = vpheight
    end

    def invalidate
      self.invalidated = true
    end
  end

  FakePages = Struct.new(:count)
  FakeModel = Struct.new(:active_view, :pages)

  def setup
    CamWheel::Data::SettingsStore.reset_memory_store!
    @timer_blocks = []
    ::UI.instance_variable_set(:@camwheel_test_last_messagebox, nil)
    ::Sketchup.instance_variable_set(:@camwheel_test_last_action, nil)
    @original_active_model =
      ::Sketchup.method(:active_model) if ::Sketchup.respond_to?(:active_model)

    ::Sketchup.singleton_class.send(:define_method, :status_text=) do |value|
      @camwheel_test_status_text = value
    end

    ::Sketchup.singleton_class.send(:define_method, :vcb_label=) do |value|
      @camwheel_test_vcb_label = value
    end

    ::Sketchup.singleton_class.send(:define_method, :vcb_value=) do |value|
      @camwheel_test_vcb_value = value
    end

    ::UI.singleton_class.send(:define_method, :messagebox) do |message|
      @camwheel_test_last_messagebox = message
    end

    ::UI.singleton_class.send(:define_method, :start_timer) do |_seconds, _repeat = false, &block|
      @camwheel_test_timer_blocks ||= []
      @camwheel_test_timer_blocks << block
      @camwheel_test_timer_blocks.length
    end

    ::UI.instance_variable_set(:@camwheel_test_timer_blocks, @timer_blocks)
    ::Sketchup.singleton_class.send(:define_method, :active_model) { FakeModel.new(nil, FakePages.new(0)) }
  end

  def test_shortcut_action_maps_control_to_ratio_cycle
    assert_equal :cycle_ratio, CamWheel::Tools::CompositionOverlayTool.shortcut_action_for(VK_CONTROL)
  end

  def test_shortcut_action_maps_alt_to_style_cycle
    assert_equal :cycle_style, CamWheel::Tools::CompositionOverlayTool.shortcut_action_for(VK_ALT)
  end

  def test_enable_vcb_for_focal_length_input
    tool = CamWheel::Tools::CompositionOverlayTool.new

    assert_equal true, tool.enableVCB?
  end

  def test_on_set_cursor_defers_to_sketchup_default_cursor
    tool = CamWheel::Tools::CompositionOverlayTool.new

    assert_equal false, tool.onSetCursor
  end

  def test_activate_updates_vcb_with_current_fov_by_default
    camera = FakeCamera.new(50.0, true, 35.0)
    view = FakeView.new(camera, false)
    model = FakeModel.new(view, FakePages.new(0))

    ::Sketchup.singleton_class.send(:define_method, :active_model) { model }

    tool = CamWheel::Tools::CompositionOverlayTool.new
    tool.activate

    assert_equal "视角(度)", ::Sketchup.instance_variable_get(:@camwheel_test_vcb_label)
    assert_equal "35", ::Sketchup.instance_variable_get(:@camwheel_test_vcb_value)
  end

  def test_on_user_text_applies_fov_in_default_mode
    camera = FakeCamera.new(50.0, false, 24.0)
    view = FakeView.new(camera, false)
    tool = CamWheel::Tools::CompositionOverlayTool.new

    tool.onUserText("35", view)

    assert_equal 35.0, camera.fov
    assert_equal true, camera.perspective_value
    assert_equal true, view.invalidated
    assert_equal "35", ::Sketchup.instance_variable_get(:@camwheel_test_vcb_value)
  end

  def test_switch_to_focal_mode_updates_vcb_label_and_applies_focal_length
    camera = FakeCamera.new(24.0, true, 53.13)
    view = FakeView.new(camera, false)
    model = FakeModel.new(view, FakePages.new(0))
    ::Sketchup.singleton_class.send(:define_method, :active_model) { model }

    tool = CamWheel::Tools::CompositionOverlayTool.new
    tool.send(:set_vcb_input_mode, "focal_length", view)

    assert_equal "focal_length", CamWheel::Data::SettingsStore.read(:composition_vcb_input_mode)
    assert_equal "焦段(mm)", ::Sketchup.instance_variable_get(:@camwheel_test_vcb_label)

    tool.onUserText("35", view)

    assert_equal 35.0, camera.focal_length
    assert_equal "35", ::Sketchup.instance_variable_get(:@camwheel_test_vcb_value)
  end

  def test_on_user_text_rejects_invalid_input_in_fov_mode
    camera = FakeCamera.new(24.0, true, 24.0)
    view = FakeView.new(camera, false)
    tool = CamWheel::Tools::CompositionOverlayTool.new

    tool.onUserText("abc", view)

    assert_equal 24.0, camera.fov
    assert_equal false, view.invalidated
    assert_equal "CamWheel 请输入有效视角", ::Sketchup.instance_variable_get(:@camwheel_test_status_text)
  end

  def test_get_menu_includes_vcb_mode_submenu
    tool = CamWheel::Tools::CompositionOverlayTool.new
    menu = FakeMenu.new

    tool.getMenu(menu)

    submenu = menu.items.find { |item| item.is_a?(FakeMenu) && item.label == "VCB输入模式" }

    refute_nil submenu
    assert_includes submenu.items.map(&:label), "视角(FOV)"
    assert_includes submenu.items.map(&:label), "焦段(mm)"
  end

  def test_get_menu_includes_save_view_action
    tool = CamWheel::Tools::CompositionOverlayTool.new
    menu = FakeMenu.new

    tool.getMenu(menu)

    assert_includes menu.items.map { |item| item.respond_to?(:label) ? item.label : item }, "保存视图"
  end

  def test_save_view_menu_action_triggers_sketchup_native_action
    tool = CamWheel::Tools::CompositionOverlayTool.new
    menu = FakeMenu.new
    pages = FakePages.new(3)
    ::Sketchup.singleton_class.send(:define_method, :active_model) { FakeModel.new(nil, pages) }

    ::Sketchup.singleton_class.send(:define_method, :platform) { :platform_win }
    ::Sketchup.singleton_class.send(:define_method, :send_action) do |action|
      @camwheel_test_last_action = action
    end

    tool.getMenu(menu)
    save_item = menu.items.find { |item| item.respond_to?(:label) && item.label == "保存视图" }

    refute_nil save_item
    save_item.block.call

    assert_equal 21180, ::Sketchup.instance_variable_get(:@camwheel_test_last_action)
    assert_equal 1, @timer_blocks.length
  end

  def test_save_view_menu_action_uses_page_add_string_on_macos
    tool = CamWheel::Tools::CompositionOverlayTool.new
    menu = FakeMenu.new
    pages = FakePages.new(3)
    ::Sketchup.singleton_class.send(:define_method, :active_model) { FakeModel.new(nil, pages) }

    ::Sketchup.singleton_class.send(:define_method, :platform) { :platform_osx }
    ::Sketchup.singleton_class.send(:define_method, :send_action) do |action|
      @camwheel_test_last_action = action
    end

    tool.getMenu(menu)
    save_item = menu.items.find { |item| item.respond_to?(:label) && item.label == "保存视图" }

    refute_nil save_item
    save_item.block.call

    assert_equal "pageAdd:", ::Sketchup.instance_variable_get(:@camwheel_test_last_action)
    assert_equal 1, @timer_blocks.length
  end

  def test_save_view_shows_success_message_only_when_page_count_increases
    tool = CamWheel::Tools::CompositionOverlayTool.new
    pages = FakePages.new(2)
    ::Sketchup.singleton_class.send(:define_method, :active_model) { FakeModel.new(nil, pages) }
    ::Sketchup.singleton_class.send(:define_method, :platform) { :platform_osx }
    ::Sketchup.singleton_class.send(:define_method, :send_action) do |_action|
      pages.count += 1
    end

    tool.send(:save_view)

    assert_equal 1, @timer_blocks.length
    assert_nil ::UI.instance_variable_get(:@camwheel_test_last_messagebox)

    @timer_blocks.first.call

    assert_equal "视角已保存", ::UI.instance_variable_get(:@camwheel_test_last_messagebox)
  end

  def test_save_view_does_not_show_success_message_when_page_count_is_unchanged
    tool = CamWheel::Tools::CompositionOverlayTool.new
    pages = FakePages.new(2)
    ::Sketchup.singleton_class.send(:define_method, :active_model) { FakeModel.new(nil, pages) }
    ::Sketchup.singleton_class.send(:define_method, :platform) { :platform_osx }
    ::Sketchup.singleton_class.send(:define_method, :send_action) do |_action|
      pages.count
    end

    tool.send(:save_view)

    assert_equal 1, @timer_blocks.length
    @timer_blocks.first.call

    assert_nil ::UI.instance_variable_get(:@camwheel_test_last_messagebox)
  end

  def test_export_image_shows_success_messagebox_when_export_succeeds
    camera = FakeCamera.new(50.0, true, 35.0)
    view = FakeView.new(camera, false)
    model = FakeModel.new(view, FakePages.new(0))
    ::Sketchup.singleton_class.send(:define_method, :active_model) { model }

    CamWheel::Services::ExportService.singleton_class.send(:define_method, :export_current_view) do |**_kwargs|
      true
    end

    tool = CamWheel::Tools::CompositionOverlayTool.new
    tool.send(:export_image, "1k")

    assert_equal "图片已导出", ::UI.instance_variable_get(:@camwheel_test_last_messagebox)
    assert_equal "CamWheel 图片导出完成", ::Sketchup.instance_variable_get(:@camwheel_test_status_text)
  end
end
