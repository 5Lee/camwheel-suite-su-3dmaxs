require_relative "../test_helper"

overlay_renderer_file = File.expand_path("../../cam_wheel/graphics/overlay_renderer.rb", __dir__)
require overlay_renderer_file if File.exist?(overlay_renderer_file)

class CamWheelOverlayRendererTest < Minitest::Test
  def test_rule_of_thirds_returns_four_guide_lines
    lines = CamWheel::Graphics::OverlayRenderer.rule_of_thirds_lines(
      x: 0,
      y: 0,
      width: 1200,
      height: 900
    )

    assert_equal 4, lines.length
  end

  def test_mask_rectangles_cover_outside_of_frame
    masks = CamWheel::Graphics::OverlayRenderer.mask_rectangles(
      viewport_width: 1600,
      viewport_height: 1200,
      frame: CamWheel::Services::CompositionService::Rect.new(100, 50, 1400, 1000)
    )

    assert_equal 4, masks.length
  end
end
