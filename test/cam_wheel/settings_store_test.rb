require_relative "../test_helper"

settings_store_file = File.expand_path("../../cam_wheel/data/settings_store.rb", __dir__)
require settings_store_file if File.exist?(settings_store_file)

class CamWheelSettingsStoreTest < Minitest::Test
  def setup
    return unless defined?(CamWheel::Data::SettingsStore)

    CamWheel::Data::SettingsStore.reset_memory_store!
  end

  def test_default_ratio_depends_on_orientation
    assert_equal "4:3", CamWheel::Data::SettingsStore.default_ratio(:landscape)
    assert_equal "3:4", CamWheel::Data::SettingsStore.default_ratio(:portrait)
  end

  def test_read_and_write_round_trip_in_memory
    CamWheel::Data::SettingsStore.write(:composition_style, "golden_ratio")

    assert_equal "golden_ratio", CamWheel::Data::SettingsStore.read(:composition_style)
  end

  def test_default_line_color_is_green
    assert_equal "#00FF66", CamWheel::Data::SettingsStore.read(:overlay_line_color)
  end
end
