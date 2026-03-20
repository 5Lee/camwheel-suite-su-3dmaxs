require_relative "../test_helper"

composition_service_file = File.expand_path("../../cam_wheel/services/composition_service.rb", __dir__)
require composition_service_file if File.exist?(composition_service_file)

class CamWheelCompositionServiceTest < Minitest::Test
  def test_fit_frame_returns_centered_inner_rect
    rect = CamWheel::Services::CompositionService.fit_frame(
      viewport_width: 1600,
      viewport_height: 1200,
      ratio_width: 4.0,
      ratio_height: 3.0
    )

    assert_equal [0, 0, 1600, 1200], rect.to_a
  end

  def test_next_style_cycles_in_declared_order
    next_style = CamWheel::Services::CompositionService.next_style("golden_spiral")

    assert_equal "diagonal", next_style
  end

  def test_display_ratio_label_uses_preset_name_for_standard_ratio
    label = CamWheel::Services::CompositionService.display_ratio_label(
      mode: "4:3",
      ratio_width: 4.0,
      ratio_height: 3.0
    )

    assert_equal "4:3", label
  end

  def test_display_ratio_label_uses_numeric_pair_for_free_ratio
    label = CamWheel::Services::CompositionService.display_ratio_label(
      mode: "free",
      ratio_width: 21.0,
      ratio_height: 9.0
    )

    assert_equal "21:9", label
  end

  def test_next_ratio_cycles_without_free_ratio
    next_ratio = CamWheel::Services::CompositionService.next_ratio("2.35:1")

    assert_equal "1:1", next_ratio
  end

  def test_spiral_corner_cycles_in_declared_order
    next_corner = CamWheel::Services::CompositionService.next_spiral_corner("top_left")

    assert_equal "top_right", next_corner
  end
end
