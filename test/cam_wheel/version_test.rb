require_relative "../test_helper"

class CamWheelVersionTest < Minitest::Test
  def test_plugin_constants_are_defined
    assert_equal "CamWheel", CamWheel::PLUGIN_NAME
    assert_equal "构图辅助仪", CamWheel::PLUGIN_NAME_ZH
    assert_equal "1.0.4", CamWheel::VERSION
    assert_equal "光影映画L", CamWheel::COMPANY
  end
end
