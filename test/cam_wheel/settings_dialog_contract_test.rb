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

  def test_ratio_options_include_common_three_four_and_four_five_presets
    payload = CamWheel::UI::UiBridge.default_payload

    assert_includes payload[:ratio_options], "3:4"
    assert_includes payload[:ratio_options], "4:5"
    assert_includes payload[:ratio_options], "5:4"
  end

  def test_payload_includes_defaults_summary_and_optional_flags
    payload = CamWheel::UI::UiBridge.default_payload

    assert_includes payload.keys, :defaults_summary
    assert_includes payload.keys, :overlay_show_label
    refute_includes payload.keys, :align_enable_two_point_perspective
  end

  def test_notice_uses_non_sticky_positioning_for_html_dialog_compatibility
    css = File.read(File.expand_path("../../cam_wheel/assets/settings.css", __dir__))

    refute_match(/\.notice\s*\{[^}]*position:\s*sticky;/m, css)
  end

  def test_notice_state_is_cleared_when_page_visibility_changes
    script = File.read(File.expand_path("../../cam_wheel/assets/settings.js", __dir__))

    assert_match(/visibilitychange/, script)
    assert_match(/clearNotice/, script)
  end

  def test_settings_ui_does_not_render_two_point_perspective_toggle
    html = File.read(File.expand_path("../../cam_wheel/assets/settings.html", __dir__))
    script = File.read(File.expand_path("../../cam_wheel/assets/settings.js", __dir__))

    refute_match(/align_enable_two_point_perspective/, html)
    refute_match(/align_enable_two_point_perspective/, script)
  end
end
