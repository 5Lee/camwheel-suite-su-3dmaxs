require_relative "../test_helper"

class CamWheelMainBootTest < Minitest::Test
  def test_loading_main_boots_plugin
    main_file = File.expand_path("../../cam_wheel/main.rb", __dir__)
    load main_file

    assert_equal true, CamWheel.instance_variable_get(:@booted)
  end
end
