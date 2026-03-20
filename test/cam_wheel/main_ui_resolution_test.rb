require_relative "../test_helper"

module ::UI
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
    attr_accessor :tooltip, :status_bar_text, :small_icon, :large_icon

    def initialize(_name, &block)
      @block = block
    end
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
  def test_build_toolbar_uses_top_level_ui_namespace
    main_file = File.expand_path("../../cam_wheel/main.rb", __dir__)
    load main_file

    toolbar = ::UI::Toolbar.instances.last

    refute_nil toolbar
    assert_equal "CamWheel", toolbar.name
    assert_equal 4, toolbar.items.length
  end
end
