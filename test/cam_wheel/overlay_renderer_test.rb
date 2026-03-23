require_relative "../test_helper"

overlay_renderer_file = File.expand_path("../../cam_wheel/graphics/overlay_renderer.rb", __dir__)
require overlay_renderer_file if File.exist?(overlay_renderer_file)

class CamWheelOverlayRendererTest < Minitest::Test
  def line_bounds(lines)
    coordinates = lines.flat_map { |line| [line.x1, line.y1, line.x2, line.y2] }
    xs = coordinates.each_slice(2).map(&:first)
    ys = coordinates.each_slice(2).map(&:last)
    [xs.min, ys.min, xs.max, ys.max]
  end

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

  def test_golden_spiral_fits_centered_golden_rectangle_in_landscape_frame
    lines = CamWheel::Graphics::OverlayRenderer.golden_spiral_lines(
      x: 0,
      y: 0,
      width: 1200,
      height: 900,
      corner: "top_left"
    )

    min_x, min_y, max_x, max_y = line_bounds(lines)

    assert_in_delta 0.0, min_x, 2.0
    assert_in_delta 79.18, min_y, 4.0
    assert_in_delta 1200.0, max_x, 2.0
    assert_in_delta 820.82, max_y, 4.0
  end

  def test_golden_spiral_follows_continuous_golden_logarithmic_rate
    renderer = CamWheel::Graphics::OverlayRenderer
    frame = renderer.send(:golden_spiral_frame, x: 0, y: 0, width: 1200, height: 900)
    anchor_points = renderer.send(:landscape_base_spiral_points, width: frame.width, height: frame.height)
    focus = renderer.send(:landscape_spiral_focus, width: frame.width, height: frame.height)
    points, transformed_focus = renderer.send(
      :transform_spiral_geometry,
      points: anchor_points,
      focus: focus,
      width: frame.width,
      height: frame.height,
      corner: "top_left"
    )
    points = renderer.send(:smooth_spiral_points, points: points, focus: transformed_focus)
    angles = renderer.send(:unwrap_spiral_angles, points: points, focus: transformed_focus)
    radii = points.map do |point_x, point_y|
      Math.sqrt(((point_x - transformed_focus[0])**2) + ((point_y - transformed_focus[1])**2))
    end
    slope = (Math.log(radii.last) - Math.log(radii.first)) / (angles.last - angles.first)

    assert_in_delta renderer::GOLDEN_SPIRAL_RATE, slope.abs, 0.06
  end
end
