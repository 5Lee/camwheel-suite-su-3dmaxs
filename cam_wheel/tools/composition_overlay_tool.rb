# frozen_string_literal: true

composition_service_file = File.join(__dir__, "..", "services", "composition_service")
overlay_renderer_file = File.join(__dir__, "..", "graphics", "overlay_renderer")
settings_store_file = File.join(__dir__, "..", "data", "settings_store")
export_service_file = File.join(__dir__, "..", "services", "export_service")

if defined?(Sketchup)
  Sketchup.require(composition_service_file)
  Sketchup.require(overlay_renderer_file)
  Sketchup.require(settings_store_file)
  Sketchup.require(export_service_file)
else
  require composition_service_file
  require overlay_renderer_file
  require settings_store_file
  require export_service_file
end

module CamWheel
  module Tools
    class CompositionOverlayTool
      SAVE_VIEW_ACTION = 21180
      FULL_FRAME_SENSOR_WIDTH_MM = 36.0
      MIN_FOV_DEGREES = 1.0
      MAX_FOV_DEGREES = 179.0
      MIN_FOCAL_LENGTH_MM = 1.0
      MAX_FOCAL_LENGTH_MM = 3000.0
      VCB_INPUT_MODE_LABELS = {
        "fov" => "视角(FOV)",
        "focal_length" => "焦段(mm)"
      }.freeze
      STYLE_LABELS = {
        "rule_of_thirds" => "九宫格",
        "golden_ratio" => "黄金分割",
        "golden_spiral" => "黄金螺旋",
        "diagonal" => "对角线"
      }.freeze
      SPIRAL_CORNER_LABELS = {
        "top_left" => "左上",
        "top_right" => "右上",
        "bottom_right" => "右下",
        "bottom_left" => "左下"
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
        @suppress_overlay = false
      end

      def active?
        @active
      end

      def enableVCB?
        true
      end

      def activate
        @active = true
        Sketchup.status_text = "CamWheel 构图辅助已开启"
        refresh_vcb(Sketchup.active_model.active_view)
        Sketchup.active_model.active_view.invalidate
      end

      def deactivate(view)
        @active = false
        view.invalidate if view
      end

      def draw(view)
        return if @suppress_overlay

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
          style_label: settings_store.read(:overlay_show_label) ? payload[:style_label] : nil,
          spiral_corner: payload[:spiral_corner]
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

      def onUserText(text, view)
        mode = current_vcb_input_mode
        numeric_value =
          case mode
          when "focal_length"
            parse_focal_length_mm(text)
          else
            parse_fov_degrees(text)
          end
        return invalid_vcb_input(mode) unless numeric_value

        apply_vcb_input(view, mode, numeric_value)
        refresh_vcb(view)
        Sketchup.status_text = vcb_status_text(mode, numeric_value)
        view.invalidate
        true
      end

      def getMenu(menu)
        menu.add_item("九宫格") { set_style("rule_of_thirds") }
        menu.add_item("黄金分割") { set_style("golden_ratio") }
        menu.add_item("黄金螺旋") { set_style("golden_spiral") }
        menu.add_item("对角线") { set_style("diagonal") }
        spiral_menu = menu.add_submenu("螺旋角度")
        SPIRAL_CORNER_LABELS.each do |corner, label|
          spiral_menu.add_item(label) { set_spiral_corner(corner) }
        end
        export_menu = menu.add_submenu("导出构图图片")
        export_menu.add_item("1K") { export_image("1k") }
        export_menu.add_item("2K") { export_image("2k") }
        export_menu.add_item("4K") { export_image("4k") }
        menu.add_item("保存视图") { save_view }
        vcb_menu = menu.add_submenu("VCB输入模式")
        vcb_menu.add_item("视角(FOV)") { set_vcb_input_mode("fov") }
        vcb_menu.add_item("焦段(mm)") { set_vcb_input_mode("focal_length") }
        menu.add_separator
        menu.add_item("切换比例") { cycle_ratio(Sketchup.active_model.active_view) }
        menu.add_item(toggle_label_menu_text) { toggle_label_visibility }
        menu.add_item("打开设置") { CamWheel.show_settings }
        menu.add_item("关闭构图辅助") { CamWheel.toggle_composition_overlay }
      end

      def resume(view)
        refresh_vcb(view)
        view.invalidate if view
      end

      def onSetCursor
        false
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
          style_label: style_display_label(style),
          ratio_label: Services::CompositionService.display_ratio_label(
            mode: ratio_mode,
            ratio_width: ratio_width,
            ratio_height: ratio_height
          ),
          ratio_width: ratio_width,
          ratio_height: ratio_height,
          spiral_corner: settings_store.read(:composition_spiral_corner)
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

      def set_spiral_corner(corner)
        settings_store.write(:composition_spiral_corner, corner)
        Sketchup.status_text = "CamWheel 螺旋角度: #{SPIRAL_CORNER_LABELS.fetch(corner, corner)}"
        Sketchup.active_model.active_view.invalidate
      end

      def export_image(preset)
        payload = current_frame_payload(Sketchup.active_model.active_view)
        exported = Services::ExportService.export_current_view(
          view: Sketchup.active_model.active_view,
          ratio_width: payload[:ratio_width],
          ratio_height: payload[:ratio_height],
          preset: preset,
          hide_overlay: method(:suppress_overlay)
        )
        ::UI.messagebox("图片已导出") if exported && defined?(::UI) && ::UI.respond_to?(:messagebox)
        Sketchup.status_text = exported ? "CamWheel 图片导出完成" : "CamWheel 已取消图片导出"
      end

      def toggle_label_visibility
        current = settings_store.read(:overlay_show_label)
        settings_store.write(:overlay_show_label, !current)
        Sketchup.active_model.active_view.invalidate
      end

      def toggle_label_menu_text
        settings_store.read(:overlay_show_label) ? "隐藏文字" : "显示文字"
      end

      def suppress_overlay(value)
        @suppress_overlay = value
      end

      def save_view
        return unless defined?(Sketchup) && Sketchup.respond_to?(:send_action)

        Sketchup.send_action(save_view_action)
      rescue StandardError
        nil
      end

      def style_display_label(style)
        return "黄金螺旋·#{SPIRAL_CORNER_LABELS.fetch(settings_store.read(:composition_spiral_corner), '')}" if style == "golden_spiral"

        STYLE_LABELS.fetch(style, style)
      end

      def settings_store
        Data::SettingsStore
      end

      def orientation(view)
        view.vpwidth >= view.vpheight ? :landscape : :portrait
      end

      def save_view_action
        return "pageAdd:" if mac_platform?

        SAVE_VIEW_ACTION
      end

      def mac_platform?
        return false unless defined?(Sketchup) && Sketchup.respond_to?(:platform)

        Sketchup.platform == :platform_osx
      rescue StandardError
        false
      end

      def current_vcb_input_mode
        settings_store.read(:composition_vcb_input_mode)
      end

      def set_vcb_input_mode(mode, view = Sketchup.active_model.active_view)
        settings_store.write(:composition_vcb_input_mode, normalize_vcb_input_mode(mode))
        refresh_vcb(view)
        Sketchup.status_text = "CamWheel VCB输入: #{VCB_INPUT_MODE_LABELS.fetch(current_vcb_input_mode)}"
        view.invalidate if view
      end

      def parse_focal_length_mm(text)
        raw = text.to_s.strip
        return nil if raw.empty?

        numeric_value = parse_plain_numeric(raw)
        return nil unless numeric_value

        focal_length = numeric_value.to_f
        return nil if focal_length < MIN_FOCAL_LENGTH_MM || focal_length > MAX_FOCAL_LENGTH_MM

        focal_length
      end

      def parse_fov_degrees(text)
        raw = text.to_s.strip
        return nil if raw.empty?

        value = parse_plain_numeric(raw)
        return nil unless value

        fov = value.to_f
        return nil if fov < MIN_FOV_DEGREES || fov > MAX_FOV_DEGREES

        fov
      end

      def parse_plain_numeric(text)
        normalized = text.strip.tr(",", ".")
        return normalized.to_f if normalized.match?(/\A[-+]?\d+(?:\.\d+)?\z/)

        parse_length_value(text)
      end

      def parse_length_value(text)
        return nil unless text.respond_to?(:to_l)

        length = text.to_l
        return length.to_mm if length.respond_to?(:to_mm)

        length.to_f
      rescue StandardError
        nil
      end

      def apply_focal_length(view, focal_length)
        camera = view.camera
        camera.perspective = true
        camera.focal_length = focal_length
      rescue StandardError
        camera.fov = focal_length_to_fov(focal_length) if camera.respond_to?(:fov=)
      end

      def apply_fov(view, fov)
        camera = view.camera
        camera.perspective = true
        camera.fov = fov
      rescue StandardError
        camera.focal_length = fov_to_focal_length(fov) if camera.respond_to?(:focal_length=)
      end

      def apply_vcb_input(view, mode, numeric_value)
        case mode
        when "focal_length"
          apply_focal_length(view, numeric_value)
        else
          apply_fov(view, numeric_value)
        end
      end

      def focal_length_to_fov(focal_length)
        radians = 2.0 * Math.atan(FULL_FRAME_SENSOR_WIDTH_MM / (2.0 * focal_length.to_f))
        radians * 180.0 / Math::PI
      end

      def fov_to_focal_length(fov)
        radians = fov.to_f * Math::PI / 180.0
        FULL_FRAME_SENSOR_WIDTH_MM / (2.0 * Math.tan(radians / 2.0))
      end

      def refresh_vcb(view)
        return unless defined?(Sketchup) && view

        mode = current_vcb_input_mode
        if Sketchup.respond_to?(:vcb_label=)
          Sketchup.vcb_label =
            case mode
            when "focal_length"
              "焦段(mm)"
            else
              "视角(度)"
            end
        end

        if Sketchup.respond_to?(:vcb_value=)
          Sketchup.vcb_value =
            case mode
            when "focal_length"
              format_focal_length_mm(current_focal_length_mm(view.camera))
            else
              format_fov_degrees(current_fov_degrees(view.camera))
            end
        end
      rescue StandardError
        nil
      end

      def current_focal_length_mm(camera)
        return camera.focal_length.to_f if camera.respond_to?(:focal_length)

        fov = camera.fov.to_f
        radians = fov * Math::PI / 180.0
        FULL_FRAME_SENSOR_WIDTH_MM / (2.0 * Math.tan(radians / 2.0))
      rescue StandardError
        35.0
      end

      def current_fov_degrees(camera)
        return camera.fov.to_f if camera.respond_to?(:fov)

        focal_length_to_fov(camera.focal_length.to_f)
      rescue StandardError
        35.0
      end

      def format_focal_length_mm(value)
        number = value.to_f.round(2)
        return number.to_i.to_s if (number - number.to_i).abs < 0.001

        format("%.2f", number).sub(/0+\z/, "").sub(/\.\z/, "")
      end

      def format_fov_degrees(value)
        number = value.to_f.round(2)
        return number.to_i.to_s if (number - number.to_i).abs < 0.001

        format("%.2f", number).sub(/0+\z/, "").sub(/\.\z/, "")
      end

      def vcb_status_text(mode, numeric_value)
        case mode
        when "focal_length"
          "CamWheel 焦段切换: #{format_focal_length_mm(numeric_value)}mm"
        else
          "CamWheel 视角切换: #{format_fov_degrees(numeric_value)}°"
        end
      end

      def invalid_vcb_input(mode)
        Sketchup.status_text =
          case mode
          when "focal_length"
            "CamWheel 请输入有效焦段"
          else
            "CamWheel 请输入有效视角"
          end
        false
      end

      def normalize_vcb_input_mode(mode)
        VCB_INPUT_MODE_LABELS.key?(mode) ? mode : DEFAULT_COMPOSITION_VCB_INPUT_MODE
      end
    end
  end
end
