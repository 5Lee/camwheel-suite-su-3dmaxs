require_relative "../test_helper"

export_service_file = File.expand_path("../../cam_wheel/services/export_service.rb", __dir__)
require export_service_file if File.exist?(export_service_file)

class CamWheelExportServiceTest < Minitest::Test
  def test_dimensions_for_4k_landscape_ratio
    width, height = CamWheel::Services::ExportService.dimensions_for(
      preset: "4k",
      ratio_width: 4.0,
      ratio_height: 3.0
    )

    assert_equal [3840, 2880], [width, height]
  end

  def test_dimensions_for_2k_portrait_ratio
    width, height = CamWheel::Services::ExportService.dimensions_for(
      preset: "2k",
      ratio_width: 9.0,
      ratio_height: 16.0
    )

    assert_equal [1440, 2560], [width, height]
  end
end
