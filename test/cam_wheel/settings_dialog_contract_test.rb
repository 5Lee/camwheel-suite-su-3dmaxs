require_relative "../test_helper"

ui_bridge_file = File.expand_path("../../cam_wheel/ui/ui_bridge.rb", __dir__)
require ui_bridge_file if File.exist?(ui_bridge_file)

class CamWheelSettingsDialogContractTest < Minitest::Test
  def test_settings_payload_contains_required_keys
    payload = CamWheel::UI::UiBridge.default_payload

    assert_includes payload.keys, :composition_ratio_mode
    assert_includes payload.keys, :overlay_mask_alpha
  end

  def test_ratio_options_exclude_free
    payload = CamWheel::UI::UiBridge.default_payload

    refute_includes payload[:ratio_options], "free"
  end
end
