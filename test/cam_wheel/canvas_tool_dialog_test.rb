require_relative "../test_helper"

module ::UI
  class HtmlDialog
    STYLE_DIALOG = :style_dialog
    @@instances = []

    def self.instances
      @@instances
    end

    attr_reader :options, :callbacks, :file

    def initialize(options)
      @options = options
      @callbacks = {}
      @@instances << self
    end

    def add_action_callback(name, &block)
      @callbacks[name] = block
    end

    def set_file(path)
      @file = path
    end

    def set_on_closed(&block)
      @on_closed = block
    end

    def show; end

    def bring_to_front; end

    def close
      @on_closed&.call
    end
  end
end

class CamWheelCanvasToolDialogTest < Minitest::Test
  def test_show_builds_dialog_with_canvas_tool_entry_html
    dialog_file = File.expand_path("../../cam_wheel/ui/canvas_tool_dialog.rb", __dir__)
    load dialog_file

    CamWheel::UI::CanvasToolDialog.show

    dialog = ::UI::HtmlDialog.instances.last

    refute_nil dialog
    assert_equal "CamWheel 拼图画布", dialog.options[:dialog_title]
    assert_equal File.expand_path("../../cam_wheel/web_canvas_tool/index.html", __dir__), File.expand_path(dialog.file)
    assert_includes dialog.callbacks.keys, "canvasToolPickImages"
    assert_includes dialog.callbacks.keys, "canvasToolSaveExport"
  end

  def test_show_rebuilds_dialog_after_close
    dialog_file = File.expand_path("../../cam_wheel/ui/canvas_tool_dialog.rb", __dir__)
    load dialog_file

    CamWheel::UI::CanvasToolDialog.show
    first_dialog = ::UI::HtmlDialog.instances.last
    first_callbacks = first_dialog.callbacks.keys

    first_dialog.close
    CamWheel::UI::CanvasToolDialog.show
    second_dialog = ::UI::HtmlDialog.instances.last

    refute_same first_dialog, second_dialog
    assert_equal first_callbacks.sort, second_dialog.callbacks.keys.sort
  end
end
