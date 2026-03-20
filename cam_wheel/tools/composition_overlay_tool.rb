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
      CONTROL_KEY = 17
      ALT_KEY = 18

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
        frame = current_frame(view)

        Graphics::OverlayRenderer.draw(
          view: view,
          frame: frame,
          style: settings_store.read(:composition_style, orientation: orientation(view)),
          mask_color: settings_store.read(:overlay_mask_color),
          mask_alpha: settings_store.read(:overlay_mask_alpha),
          line_color: settings_store.read(:overlay_line_color),
          line_width: settings_store.read(:overlay_line_width)
        )
      end

      def onKeyDown(key, _repeat, _flags, view)
        case key
        when CONTROL_KEY
          cycle_ratio(view)
        when ALT_KEY
          cycle_style(view)
        end
      end

      def getMenu(menu)
        menu.add_item("九宫格") { set_style("rule_of_thirds") }
        menu.add_item("黄金分割") { set_style("golden_ratio") }
        menu.add_item("黄金螺旋") { set_style("golden_spiral") }
        menu.add_item("对角线") { set_style("diagonal") }
        menu.add_separator
        menu.add_item("切换比例") { cycle_ratio(Sketchup.active_model.active_view) }
        menu.add_item("打开设置") { CamWheel.show_settings }
        menu.add_item("关闭构图辅助") { CamWheel.toggle_composition_overlay }
      end

      private

      def current_frame(view)
        ratio_mode = settings_store.read(:composition_ratio_mode, orientation: orientation(view))
        ratio_width, ratio_height = Services::CompositionService.ratio_dimensions(
          mode: ratio_mode,
          orientation: orientation(view),
          free_width: settings_store.read(:composition_free_ratio_width),
          free_height: settings_store.read(:composition_free_ratio_height)
        )

        Services::CompositionService.fit_frame(
          viewport_width: view.vpwidth,
          viewport_height: view.vpheight,
          ratio_width: ratio_width,
          ratio_height: ratio_height
        )
      end

      def cycle_ratio(view)
        current = settings_store.read(:composition_ratio_mode, orientation: orientation(view))
        settings_store.write(:composition_ratio_mode, Services::CompositionService.next_ratio(current))
        view.invalidate
      end

      def cycle_style(view)
        current = settings_store.read(:composition_style)
        settings_store.write(:composition_style, Services::CompositionService.next_style(current))
        view.invalidate
      end

      def set_style(style)
        settings_store.write(:composition_style, style)
        Sketchup.active_model.active_view.invalidate
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
