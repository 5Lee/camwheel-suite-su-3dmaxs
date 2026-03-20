# frozen_string_literal: true

version_file = File.join(__dir__, "version")

if defined?(Sketchup)
  Sketchup.require(version_file)
else
  require version_file
end

module CamWheel
  EXTENSION_MAIN_FILE = File.join(__dir__, "main").freeze

  def self.register_extension
    return unless defined?(SketchupExtension) && defined?(Sketchup)
    return if defined?(@extension_registered) && @extension_registered

    extension = SketchupExtension.new(PLUGIN_NAME_ZH, EXTENSION_MAIN_FILE)
    extension.name = PLUGIN_NAME
    extension.description = PLUGIN_NAME_ZH
    extension.version = VERSION
    extension.creator = COMPANY

    Sketchup.register_extension(extension, true)
    @extension_registered = true
  end
end
