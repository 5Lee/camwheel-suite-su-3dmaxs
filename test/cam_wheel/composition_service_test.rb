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
end
