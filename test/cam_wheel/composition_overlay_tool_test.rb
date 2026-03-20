require_relative "../test_helper"

composition_overlay_tool_file = File.expand_path("../../cam_wheel/tools/composition_overlay_tool.rb", __dir__)
require composition_overlay_tool_file if File.exist?(composition_overlay_tool_file)

unless defined?(VK_CONTROL)
  VK_CONTROL = 17
end

unless defined?(VK_ALT)
  VK_ALT = 18
end

class CamWheelCompositionOverlayToolTest < Minitest::Test
  def test_shortcut_action_maps_control_to_ratio_cycle
    assert_equal :cycle_ratio, CamWheel::Tools::CompositionOverlayTool.shortcut_action_for(VK_CONTROL)
  end

  def test_shortcut_action_maps_alt_to_style_cycle
    assert_equal :cycle_style, CamWheel::Tools::CompositionOverlayTool.shortcut_action_for(VK_ALT)
  end
end
