require "minitest/autorun"

version_file = File.expand_path("../cam_wheel/version.rb", __dir__)
require version_file if File.exist?(version_file)
