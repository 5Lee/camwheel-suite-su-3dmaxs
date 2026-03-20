# frozen_string_literal: true

composition_service_file = File.join(__dir__, "..", "services", "composition_service")

if defined?(Sketchup)
  Sketchup.require(composition_service_file)
else
  require composition_service_file
end

module CamWheel
  module Graphics
    module OverlayRenderer
      Line = Struct.new(:x1, :y1, :x2, :y2) do
        def to_a
          [x1, y1, x2, y2]
        end
      end

      Rectangle = Struct.new(:x, :y, :width, :height) do
        def to_a
          [x, y, width, height]
        end
      end

      GOLDEN_RATIO = ((1.0 + Math.sqrt(5.0)) / 2.0).freeze

      class << self
        def mask_rectangles(viewport_width:, viewport_height:, frame:)
          [
            Rectangle.new(0, 0, viewport_width, frame.y),
            Rectangle.new(0, frame.y, frame.x, frame.height),
            Rectangle.new(frame.x + frame.width, frame.y, viewport_width - frame.x - frame.width, frame.height),
            Rectangle.new(0, frame.y + frame.height, viewport_width, viewport_height - frame.y - frame.height)
          ]
        end

        def lines_for(style:, frame:)
          case style
          when "golden_ratio"
            golden_ratio_lines(x: frame.x, y: frame.y, width: frame.width, height: frame.height)
          when "golden_spiral"
            golden_spiral_lines(x: frame.x, y: frame.y, width: frame.width, height: frame.height)
          when "diagonal"
            diagonal_lines(x: frame.x, y: frame.y, width: frame.width, height: frame.height)
          else
            rule_of_thirds_lines(x: frame.x, y: frame.y, width: frame.width, height: frame.height)
          end
        end

        def rule_of_thirds_lines(x:, y:, width:, height:)
          first_x = x + (width / 3.0)
          second_x = x + ((width * 2.0) / 3.0)
          first_y = y + (height / 3.0)
          second_y = y + ((height * 2.0) / 3.0)

          [
            Line.new(first_x, y, first_x, y + height),
            Line.new(second_x, y, second_x, y + height),
            Line.new(x, first_y, x + width, first_y),
            Line.new(x, second_y, x + width, second_y)
          ]
        end

        def golden_ratio_lines(x:, y:, width:, height:)
          x_offset = width / GOLDEN_RATIO
          y_offset = height / GOLDEN_RATIO

          [
            Line.new(x + x_offset, y, x + x_offset, y + height),
            Line.new(x + width - x_offset, y, x + width - x_offset, y + height),
            Line.new(x, y + y_offset, x + width, y + y_offset),
            Line.new(x, y + height - y_offset, x + width, y + height - y_offset)
          ]
        end

        def diagonal_lines(x:, y:, width:, height:)
          [
            Line.new(x, y, x + width, y + height),
            Line.new(x + width, y, x, y + height)
          ]
        end

        def golden_spiral_lines(x:, y:, width:, height:)
          square = [width, height].min
          step = square / 4.0

          [
            Line.new(x + square, y, x + square, y + square),
            Line.new(x + square, y + square, x + (square - step), y + square),
            Line.new(x + (square - step), y + square, x + (square - step), y + step),
            Line.new(x + (square - step), y + step, x + step, y + step),
            Line.new(x + step, y + step, x + step, y + (square - step)),
            Line.new(x + step, y + (square - step), x + (square / 2.0), y + (square - step))
          ]
        end

        def draw(view:, frame:, style:, mask_color:, mask_alpha:, line_color:, line_width:)
          draw_masks(view, mask_rectangles(viewport_width: view.vpwidth, viewport_height: view.vpheight, frame: frame), mask_color, mask_alpha)
          draw_lines(view, lines_for(style: style, frame: frame), line_color, line_width)
        end

        private

        def draw_masks(view, rectangles, color, alpha)
          rectangles.each do |rectangle|
            next if rectangle.width <= 0 || rectangle.height <= 0

            points = [
              Geom::Point3d.new(rectangle.x, rectangle.y, 0),
              Geom::Point3d.new(rectangle.x + rectangle.width, rectangle.y, 0),
              Geom::Point3d.new(rectangle.x + rectangle.width, rectangle.y + rectangle.height, 0),
              Geom::Point3d.new(rectangle.x, rectangle.y + rectangle.height, 0)
            ]

            view.drawing_color = color_for(color, alpha)
            view.draw2d(GL_QUADS, points)
          end
        end

        def draw_lines(view, lines, color, width)
          view.drawing_color = color_for(color, 255)
          view.line_width = width.to_i

          lines.each do |line|
            points = [
              Geom::Point3d.new(line.x1, line.y1, 0),
              Geom::Point3d.new(line.x2, line.y2, 0)
            ]
            view.draw2d(GL_LINES, points)
          end
        end

        def color_for(hex_color, alpha)
          color_string = hex_color.to_s.delete_prefix("#")
          red = color_string[0, 2].to_i(16)
          green = color_string[2, 2].to_i(16)
          blue = color_string[4, 2].to_i(16)

          Sketchup::Color.new(red, green, blue, alpha_to_channel(alpha))
        end

        def alpha_to_channel(alpha)
          return alpha if alpha.is_a?(Integer)

          [(alpha.to_f * 255.0).round, 255].min
        end
      end
    end
  end
end
