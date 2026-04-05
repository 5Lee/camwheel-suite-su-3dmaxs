require_relative "../test_helper"

canvas_tool_bridge_file = File.expand_path("../../cam_wheel/ui/canvas_tool_bridge.rb", __dir__)
require canvas_tool_bridge_file if File.exist?(canvas_tool_bridge_file)

unless defined?(UI)
  module ::UI
  end
end

class CamWheelCanvasToolBridgeTest < Minitest::Test
  FakeDialog = Struct.new(:callbacks) do
    def add_action_callback(name, &block)
      callbacks[name] = block
    end
  end

  FakeContext = Struct.new(:dummy)

  def setup
    ::UI.singleton_class.send(:define_method, :openpanel) do |*_args|
      ["/tmp/a.jpg", "/tmp/b.jpg"]
    end

    ::UI.singleton_class.send(:define_method, :savepanel) do |*_args|
      "/tmp/collage-export.jpg"
    end
  end

  def test_bind_registers_pick_and_save_callbacks
    dialog = FakeDialog.new({})

    CamWheel::UI::CanvasToolBridge.bind(dialog)

    assert_includes dialog.callbacks.keys, "canvasToolPickImages"
    assert_includes dialog.callbacks.keys, "canvasToolSaveExport"
  end

  def test_pick_images_callback_uses_top_level_ui_openpanel
    dialog = FakeDialog.new({})

    CamWheel::UI::CanvasToolBridge.bind(dialog)
    result = dialog.callbacks.fetch("canvasToolPickImages").call(FakeContext.new(nil))

    assert_equal ["/tmp/a.jpg", "/tmp/b.jpg"], result
  end

  def test_save_export_callback_uses_top_level_ui_savepanel
    dialog = FakeDialog.new({})

    CamWheel::UI::CanvasToolBridge.bind(dialog)
    result = dialog.callbacks.fetch("canvasToolSaveExport").call(FakeContext.new(nil), "collage-export.jpg")

    assert_equal "/tmp/collage-export.jpg", result
  end
end
