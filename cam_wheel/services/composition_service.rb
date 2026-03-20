# frozen_string_literal: true

version_file = File.join(__dir__, "..", "version")
constants_file = File.join(__dir__, "..", "constants")
settings_store_file = File.join(__dir__, "..", "data", "settings_store")

if defined?(Sketchup)
  Sketchup.require(version_file)
  Sketchup.require(constants_file)
  Sketchup.require(settings_store_file)
else
  require version_file
  require constants_file
  require settings_store_file
end

module CamWheel
  module Services
    class CompositionService
      Rect = Struct.new(:x, :y, :width, :height) do
        def to_a
          [x, y, width, height]
        end
      end

      STYLE_ORDER = %w[rule_of_thirds golden_ratio golden_spiral diagonal].freeze
      RATIO_ORDER = %w[free 1:1 4:3 3:2 16:9 9:16 2.35:1].freeze
      PRESET_DIMENSIONS = {
        "1:1" => [1.0, 1.0].freeze,
        "4:3" => [4.0, 3.0].freeze,
        "3:4" => [3.0, 4.0].freeze,
        "3:2" => [3.0, 2.0].freeze,
        "16:9" => [16.0, 9.0].freeze,
        "9:16" => [9.0, 16.0].freeze,
        "2.35:1" => [2.35, 1.0].freeze
      }.freeze

      class << self
        def fit_frame(viewport_width:, viewport_height:, ratio_width:, ratio_height:)
          frame_ratio = ratio_width.to_f / ratio_height.to_f
          viewport_ratio = viewport_width.to_f / viewport_height.to_f

          if viewport_ratio > frame_ratio
            height = viewport_height
            width = (height * frame_ratio).round
            x = ((viewport_width - width) / 2.0).round
            y = 0
          else
            width = viewport_width
            height = (width / frame_ratio).round
            x = 0
            y = ((viewport_height - height) / 2.0).round
          end

          Rect.new(x, y, width, height)
        end

        def next_style(style)
          cycle_value(STYLE_ORDER, style)
        end

        def next_ratio(mode)
          cycle_value(RATIO_ORDER, mode)
        end

        def ratio_dimensions(mode:, orientation:, free_width: nil, free_height: nil)
          return normalize_ratio(free_width, free_height) if mode == "free"

          PRESET_DIMENSIONS.fetch(mode) { PRESET_DIMENSIONS.fetch(default_ratio_for_orientation(orientation)) }
        end

        def default_ratio_for_orientation(orientation)
          Data::SettingsStore.default_ratio(orientation)
        end

        def normalize_ratio(width, height)
          normalized_width = width.to_f
          normalized_height = height.to_f

          if normalized_width <= 0.0 || normalized_height <= 0.0
            [DEFAULT_FREE_RATIO_WIDTH, DEFAULT_FREE_RATIO_HEIGHT]
          else
            [normalized_width, normalized_height]
          end
        end

        private

        def cycle_value(order, current)
          current_index = order.index(current) || -1
          order[(current_index + 1) % order.length]
        end
      end
    end
  end
end
