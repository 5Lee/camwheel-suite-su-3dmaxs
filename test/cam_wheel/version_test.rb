require_relative "../test_helper"

class CamWheelVersionTest < Minitest::Test
  def test_plugin_constants_are_defined
    assert_equal "CamWheel", CamWheel::PLUGIN_NAME
    assert_equal "构图辅助仪", CamWheel::PLUGIN_NAME_ZH
  end
end
