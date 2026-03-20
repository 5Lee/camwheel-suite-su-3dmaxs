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

  def test_golden_ratio_lines_use_golden_section_not_thirds
    golden = CamWheel::Graphics::OverlayRenderer.golden_ratio_lines(
      x: 0,
      y: 0,
      width: 1200,
      height: 900
    )
    thirds = CamWheel::Graphics::OverlayRenderer.rule_of_thirds_lines(
      x: 0,
      y: 0,
      width: 1200,
      height: 900
    )

    refute_in_delta thirds.first.x1, golden.first.x1, 5.0
  end

  def test_golden_spiral_contains_curved_like_segments
    lines = CamWheel::Graphics::OverlayRenderer.golden_spiral_lines(
      x: 0,
      y: 0,
      width: 1200,
      height: 900,
      corner: "top_left"
    )

    assert_operator lines.length, :>, 12
    assert lines.any? { |line| line.x1 != line.x2 && line.y1 != line.y2 }
  end

  def test_golden_spiral_corner_changes_geometry
    top_left = CamWheel::Graphics::OverlayRenderer.golden_spiral_lines(
      x: 0,
      y: 0,
      width: 1200,
      height: 900,
      corner: "top_left"
    )
    top_right = CamWheel::Graphics::OverlayRenderer.golden_spiral_lines(
      x: 0,
      y: 0,
      width: 1200,
      height: 900,
      corner: "top_right"
    )

    refute_equal top_left.first.to_a, top_right.first.to_a
  end
end
