require_relative "../test_helper"

ui_bridge_file = File.expand_path("../../cam_wheel/ui/ui_bridge.rb", __dir__)
require ui_bridge_file if File.exist?(ui_bridge_file)

class CamWheelUiBridgeBindingTest < Minitest::Test
  FakeDialog = Struct.new(:callbacks, :scripts) do
    def add_action_callback(name, &block)
      callbacks[name] = block
    end

    def execute_script(script)
      scripts << script
    end
  end

  FakeContext = Struct.new(:dummy)

  def test_ready_callback_pushes_payload_via_execute_script
    dialog = FakeDialog.new({}, [])

    CamWheel::UI::UiBridge.bind(dialog)
    dialog.callbacks.fetch("camWheelReady").call(FakeContext.new(nil))

    assert_equal 1, dialog.scripts.length
    assert_includes dialog.scripts.first, "receivePayload"
  end
end
