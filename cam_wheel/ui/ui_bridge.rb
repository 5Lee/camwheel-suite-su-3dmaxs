# frozen_string_literal: true

require "json"

settings_store_file = File.join(__dir__, "..", "data", "settings_store")

if defined?(Sketchup)
  Sketchup.require(settings_store_file)
else
  require settings_store_file
end

module CamWheel
  module UI
    module UiBridge
      RATIO_OPTIONS = ["1:1", "4:3", "3:2", "16:9", "9:16", "2.35:1"].freeze
      STYLE_OPTIONS = %w[rule_of_thirds golden_ratio golden_spiral diagonal].freeze

      class << self
        def bind(dialog)
          dialog.add_action_callback("camWheelReady") do |action_context|
            action_context.respond(default_payload.to_json)
          end

          dialog.add_action_callback("camWheelSave") do |action_context, payload|
            save_payload(payload)
            action_context.respond(default_payload.to_json)
            refresh_active_view
          end

          dialog.add_action_callback("camWheelReset") do |action_context|
            reset_defaults
            action_context.respond(default_payload.to_json)
            refresh_active_view
          end
        end

        def default_payload
          orientation = current_orientation
          settings = Data::SettingsStore.defaults(orientation: orientation)

          settings.merge(
            ratio_options: RATIO_OPTIONS,
            style_options: STYLE_OPTIONS
          )
        end

        def save_payload(payload)
          data = payload.is_a?(String) ? JSON.parse(payload) : payload

          permitted_keys.each do |key|
            string_key = key.to_s
            next unless data.key?(string_key)

            Data::SettingsStore.write(key, normalize_value(key, data[string_key]))
          end
        end

        def reset_defaults
          permitted_keys.each do |key|
            value =
              if key == :composition_ratio_mode
                Data::SettingsStore.default_ratio(current_orientation)
              else
                Data::SettingsStore::DEFAULTS.fetch(key)
              end
            Data::SettingsStore.write(key, value)
          end
        end

        private

        def permitted_keys
          Data::SettingsStore::DEFAULTS.keys
        end

        def current_orientation
          return :landscape unless defined?(Sketchup)

          view = Sketchup.active_model.active_view
          view.vpwidth >= view.vpheight ? :landscape : :portrait
        rescue StandardError
          :landscape
        end

        def refresh_active_view
          return unless defined?(Sketchup)

          Sketchup.active_model.active_view.invalidate
        rescue StandardError
          nil
        end

        def normalize_value(key, value)
          case key
          when :composition_free_ratio_width, :composition_free_ratio_height, :overlay_line_width, :overlay_mask_alpha, :penetration_offset
            value.to_f
          when :align_enable_two_point_perspective, :overlay_show_label
            value == true || value.to_s == "true"
          else
            value
          end
        end
      end
    end
  end
end
