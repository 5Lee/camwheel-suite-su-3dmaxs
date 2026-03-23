require_relative "../test_helper"

require "open3"
require "tmpdir"

class CamWheelBuildRbzScriptTest < Minitest::Test
  def test_build_script_creates_rbz_with_runtime_files_only
    script_path = File.expand_path("../../scripts/build_rbz.sh", __dir__)
    repo_root = File.expand_path("../..", __dir__)

    Dir.mktmpdir("camwheel-rbz") do |dir|
      stdout, stderr, status = Open3.capture3(
        { "OUTPUT_DIR" => dir },
        "bash",
        script_path,
        chdir: repo_root
      )

      assert status.success?, "build script failed:\nSTDOUT:\n#{stdout}\nSTDERR:\n#{stderr}"

      archive_path = File.join(dir, "CamWheel-#{CamWheel::VERSION}.rbz")
      assert File.exist?(archive_path), "expected archive at #{archive_path}"

      listing, unzip_status = Open3.capture2("unzip", "-l", archive_path)
      assert unzip_status.success?, "unable to inspect archive:\n#{listing}"

      assert_includes listing, "CamWheel.rb"
      assert_includes listing, "cam_wheel/tools/composition_overlay_tool.rb"
      refute_includes listing, "test/"
      refute_includes listing, "docs/"
      refute_includes listing, "测试.skp"
    end
  end
end
