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
    @@instances = []

    def self.instances
      @@instances
    end

    attr_reader :name, :items

    def initialize(name)
      @name = name
      @items = []
      @@instances << self
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
  end

  def self.menu(name)
    Menu.named(name)
  end
end

module ::Sketchup
  def self.require(path)
    Kernel.require path
  end

  def self.active_model
    raise "not needed in this test"
  end
end

class CamWheelMainUiResolutionTest < Minitest::Test
  def setup
    ::UI::Menu.reset!
    CamWheel.instance_variable_set(:@booted, nil) if defined?(CamWheel)
  end

  def test_build_toolbar_uses_top_level_ui_namespace
    main_file = File.expand_path("../../cam_wheel/main.rb", __dir__)
    load main_file

    toolbar = ::UI::Toolbar.instances.last

    refute_nil toolbar
    assert_equal "CamWheel", toolbar.name
    assert_equal 6, toolbar.items.length
  end

  def test_builds_extensions_submenu_with_individual_commands
    main_file = File.expand_path("../../cam_wheel/main.rb", __dir__)
    load main_file

    extensions_menu = ::UI.menu("Extensions")
    submenu = extensions_menu.items.find { |item| item.is_a?(::UI::Menu) && item.name == "CamWheel" }

    refute_nil submenu
    assert_equal 6, submenu.items.length
  end
end
