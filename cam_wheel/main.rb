# frozen_string_literal: true

constants_file = File.join(__dir__, "constants")

if defined?(Sketchup)
  Sketchup.require(constants_file)
else
  require constants_file
end

module CamWheel
  def self.boot
    return if defined?(@booted) && @booted

    @booted = true
  end
end
