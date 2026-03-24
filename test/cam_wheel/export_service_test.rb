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

  def test_default_filename_uses_model_name_and_timestamp
    filename = CamWheel::Services::ExportService.send(
      :default_filename,
      model_path: "/tmp/My House.skp",
      exported_at: Time.new(2026, 3, 23, 15, 30, 45, "+08:00")
    )

    assert_equal "My House-20260323-153045.jpg", filename
  end

  def test_default_filename_falls_back_when_model_has_not_been_saved
    filename = CamWheel::Services::ExportService.send(
      :default_filename,
      model_path: "",
      exported_at: Time.new(2026, 3, 23, 15, 30, 45, "+08:00")
    )

    assert_equal "camwheel-20260323-153045.jpg", filename
  end
end
