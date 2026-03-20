# frozen_string_literal: true

composition_service_file = File.join(__dir__, "..", "services", "composition_service")
overlay_renderer_file = File.join(__dir__, "..", "graphics", "overlay_renderer")
settings_store_file = File.join(__dir__, "..", "data", "settings_store")

if defined?(Sketchup)
  Sketchup.require(composition_service_file)
  Sketchup.require(overlay_renderer_file)
  Sketchup.require(settings_store_file)
else
  require composition_service_file
  require overlay_renderer_file
  require settings_store_file
end

module CamWheel
  module Tools
    class CompositionOverlayTool
      STYLE_LABELS = {
        "rule_of_thirds" => "九宫格",
        "golden_ratio" => "黄金分割",
        "golden_spiral" => "黄金螺旋",
        "diagonal" => "对角线"
      }.freeze

      class << self
        def shortcut_action_for(key)
          return :cycle_ratio if ratio_shortcut_keys.include?(key)
          return :cycle_style if style_shortcut_keys.include?(key)

          nil
        end

        private

        def ratio_shortcut_keys
          @ratio_shortcut_keys ||= [lookup_key_constant("VK_CONTROL"), 17].compact.uniq
        end

        def style_shortcut_keys
          @style_shortcut_keys ||= [lookup_key_constant("VK_ALT"), lookup_key_constant("VK_MENU"), 18].compact.uniq
        end

        def lookup_key_constant(name)
          Object.const_get(name) if Object.const_defined?(name)
        end
      end

      def initialize
        @active = false
      end

      def active?
        @active
      end

      def activate
        @active = true
        Sketchup.status_text = "CamWheel 构图辅助已开启"
        Sketchup.active_model.active_view.invalidate
      end

      def deactivate(view)
        @active = false
        view.invalidate if view
      end

      def draw(view)
        payload = current_frame_payload(view)

        Graphics::OverlayRenderer.draw(
          view: view,
          frame: payload[:frame],
          style: payload[:style],
          mask_color: settings_store.read(:overlay_mask_color),
          mask_alpha: settings_store.read(:overlay_mask_alpha),
          line_color: settings_store.read(:overlay_line_color),
          line_width: settings_store.read(:overlay_line_width),
          ratio_label: settings_store.read(:overlay_show_label) ? payload[:ratio_label] : nil,
          style_label: settings_store.read(:overlay_show_label) ? payload[:style_label] : nil
        )
      end

      def onKeyDown(key, repeat, _flags, view)
        return false if repeat.to_i > 1

        case self.class.shortcut_action_for(key)
        when :cycle_ratio
          cycle_ratio(view)
          true
        when :cycle_style
          cycle_style(view)
          true
        else
          false
        end
      end

      def getMenu(menu)
        menu.add_item("九宫格") { set_style("rule_of_thirds") }
        menu.add_item("黄金分割") { set_style("golden_ratio") }
        menu.add_item("黄金螺旋") { set_style("golden_spiral") }
        menu.add_item("对角线") { set_style("diagonal") }
        menu.add_separator
        menu.add_item("切换比例") { cycle_ratio(Sketchup.active_model.active_view) }
        menu.add_item(toggle_label_menu_text) { toggle_label_visibility }
        menu.add_item("打开设置") { CamWheel.show_settings }
        menu.add_item("关闭构图辅助") { CamWheel.toggle_composition_overlay }
      end

      def resume(view)
        view.invalidate if view
      end

      def suspend(view)
        view.invalidate if view
      end

      def onMouseWheel(_flags, _delta, _x, _y, view)
        view.invalidate if view
      end

      def onMouseMove(_flags, _x, _y, view)
        view.invalidate if view
      end

      def onMButtonUp(_flags, _x, _y, view)
        view.invalidate if view
      end

      def onMouseEnter(view)
        view.invalidate if view
      end

      private

      def current_frame_payload(view)
        ratio_mode = settings_store.read(:composition_ratio_mode, orientation: orientation(view))
        ratio_width, ratio_height = Services::CompositionService.ratio_dimensions(
          mode: ratio_mode,
          orientation: orientation(view),
          free_width: settings_store.read(:composition_free_ratio_width),
          free_height: settings_store.read(:composition_free_ratio_height)
        )

        frame = Services::CompositionService.fit_frame(
          viewport_width: view.vpwidth,
          viewport_height: view.vpheight,
          ratio_width: ratio_width,
          ratio_height: ratio_height
        )

        style = settings_store.read(:composition_style, orientation: orientation(view))

        {
          frame: frame,
          style: style,
          style_label: STYLE_LABELS.fetch(style, style),
          ratio_label: Services::CompositionService.display_ratio_label(
            mode: ratio_mode,
            ratio_width: ratio_width,
            ratio_height: ratio_height
          )
        }
      end

      def cycle_ratio(view)
        current = settings_store.read(:composition_ratio_mode, orientation: orientation(view))
        next_ratio = Services::CompositionService.next_ratio(current)
        settings_store.write(:composition_ratio_mode, next_ratio)
        Sketchup.status_text = "CamWheel 比例切换: #{next_ratio}"
        view.invalidate
      end

      def cycle_style(view)
        current = settings_store.read(:composition_style)
        next_style = Services::CompositionService.next_style(current)
        settings_store.write(:composition_style, next_style)
        Sketchup.status_text = "CamWheel 构图线切换: #{STYLE_LABELS.fetch(next_style, next_style)}"
        view.invalidate
      end

      def set_style(style)
        settings_store.write(:composition_style, style)
        Sketchup.active_model.active_view.invalidate
      end

      def toggle_label_visibility
        current = settings_store.read(:overlay_show_label)
        settings_store.write(:overlay_show_label, !current)
        Sketchup.active_model.active_view.invalidate
      end

      def toggle_label_menu_text
        settings_store.read(:overlay_show_label) ? "隐藏文字" : "显示文字"
      end

      def settings_store
        Data::SettingsStore
      end

      def orientation(view)
        view.vpwidth >= view.vpheight ? :landscape : :portrait
      end
    end
  end
end
