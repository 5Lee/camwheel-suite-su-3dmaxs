require_relative "../test_helper"

module ::UI
  class Menu
    @@menus = {}

    def self.named(name)
      @@menus[name] ||= new(name)
    end

    def self.reset!
      @@menus = {}
    end

    attr_reader :name, :items

    def initialize(name)
      @name = name
      @items = []
    end

    def add_item(item = nil, &block)
      @items << (item || block)
    end

    def add_submenu(name)
      submenu = self.class.new(name)
      @items << submenu
      submenu
    end
  end

  class Toolbar
    def initialize(_name)
      @items = []
    end

    def add_item(item)
      @items << item
    end

    def restore
      true
    end
  end

  class Command
    attr_accessor :tooltip, :status_bar_text, :small_icon, :large_icon, :menu_text

    def initialize(_name, &block)
      @block = block
    end

    def call
      @block.call
    end
  end

  def self.menu(name)
    Menu.named(name)
  end
end

module ::Sketchup
  class FakeModel
    attr_reader :selected_tools

    def initialize
      @selected_tools = []
    end

    def select_tool(tool)
      @selected_tools << tool
    end
  end

  def self.require(path)
    Kernel.require path
  end

  def self.active_model
    @camwheel_test_model ||= FakeModel.new
  end
end

class CamWheelMainToolReferenceTest < Minitest::Test
  def setup
    ::UI::Menu.reset!
    ::Sketchup.instance_variable_set(:@camwheel_test_model, nil)
    CamWheel.instance_variable_set(:@booted, nil) if defined?(CamWheel)
    CamWheel.instance_variable_set(:@canvas_tool_command, nil) if defined?(CamWheel)
    CamWheel.instance_variable_set(:@align_view_command, nil) if defined?(CamWheel)
    CamWheel.instance_variable_set(:@penetration_command, nil) if defined?(CamWheel)
    CamWheel.instance_variable_set(:@align_view_tool, nil) if defined?(CamWheel)
    CamWheel.instance_variable_set(:@penetration_tool, nil) if defined?(CamWheel)
  end

  def test_align_view_command_reuses_retained_tool_instance
    main_file = File.expand_path("../../cam_wheel/main.rb", __dir__)
    load main_file

    model = ::Sketchup.active_model
    command = CamWheel.send(:align_view_command)

    command.call
    first_tool = model.selected_tools.last

    command.call
    second_tool = model.selected_tools.last

    assert_same first_tool, second_tool
  end

  def test_penetration_command_reuses_retained_tool_instance
    main_file = File.expand_path("../../cam_wheel/main.rb", __dir__)
    load main_file

    model = ::Sketchup.active_model
    command = CamWheel.send(:penetration_command)

    command.call
    first_tool = model.selected_tools.last

    command.call
    second_tool = model.selected_tools.last

    assert_same first_tool, second_tool
  end

  def test_canvas_tool_command_is_defined
    main_file = File.expand_path("../../cam_wheel/main.rb", __dir__)
    load main_file

    command = CamWheel.send(:canvas_tool_command)

    refute_nil command
  end
end
