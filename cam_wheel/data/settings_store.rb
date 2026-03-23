# frozen_string_literal: true

version_file = File.join(__dir__, "..", "version")
constants_file = File.join(__dir__, "..", "constants")

if defined?(Sketchup)
  Sketchup.require(version_file)
  Sketchup.require(constants_file)
else
  require version_file
  require constants_file
end

module CamWheel
  module Data
    class SettingsStore
      DEFAULTS = {
        composition_ratio_mode: nil,
        composition_vcb_input_mode: DEFAULT_COMPOSITION_VCB_INPUT_MODE,
        composition_free_ratio_width: DEFAULT_FREE_RATIO_WIDTH,
        composition_free_ratio_height: DEFAULT_FREE_RATIO_HEIGHT,
        composition_style: DEFAULT_COMPOSITION_STYLE,
        composition_spiral_corner: DEFAULT_SPIRAL_CORNER,
        overlay_line_color: DEFAULT_LINE_COLOR,
        overlay_line_width: DEFAULT_LINE_WIDTH,
        overlay_mask_color: DEFAULT_MASK_COLOR,
        overlay_mask_alpha: DEFAULT_MASK_ALPHA,
        overlay_show_label: DEFAULT_OVERLAY_SHOW_LABEL,
        penetration_offset: DEFAULT_PENETRATION_OFFSET
      }.freeze

      class << self
        def default_ratio(orientation)
          orientation == :portrait ? DEFAULT_COMPOSITION_RATIO_PORTRAIT : DEFAULT_COMPOSITION_RATIO_LANDSCAPE
        end

        def read(key, orientation: :landscape)
          validate_key!(key)

          value = read_raw(key)
          return value unless value.nil?

          key == :composition_ratio_mode ? default_ratio(orientation) : DEFAULTS.fetch(key)
        end

        def write(key, value)
          validate_key!(key)
          write_raw(key, value)
        end

        def defaults(orientation: :landscape)
          DEFAULTS.each_with_object({}) do |(key, _value), memo|
            memo[key] = read(key, orientation: orientation)
          end
        end

        def reset_memory_store!
          @memory_store = {}
        end

        private

        def validate_key!(key)
          return if DEFAULTS.key?(key)

          raise ArgumentError, "Unknown CamWheel setting: #{key}"
        end

        def storage_key(key)
          key.to_s
        end

        def read_raw(key)
          if defined?(Sketchup) && Sketchup.respond_to?(:read_default)
            Sketchup.read_default(SETTINGS_NAMESPACE, storage_key(key), nil)
          else
            memory_store[storage_key(key)]
          end
        end

        def write_raw(key, value)
          if defined?(Sketchup) && Sketchup.respond_to?(:write_default)
            Sketchup.write_default(SETTINGS_NAMESPACE, storage_key(key), value)
          else
            memory_store[storage_key(key)] = value
          end
        end

        def memory_store
          @memory_store ||= {}
        end
      end
    end
  end
end
