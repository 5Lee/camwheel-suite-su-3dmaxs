# frozen_string_literal: true

extension_file = File.join(__dir__, "cam_wheel", "extension")

if defined?(Sketchup)
  Sketchup.require(extension_file)
else
  require extension_file
end

CamWheel.register_extension if defined?(CamWheel)
