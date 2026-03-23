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
      GOLDEN_SPIRAL_RATE = ((2.0 * Math.log(GOLDEN_RATIO)) / Math::PI).freeze
      GOLDEN_SPIRAL_SEGMENTS = 8
      SMOOTH_SPIRAL_SEGMENTS = 96

      class << self
        def mask_rectangles(viewport_width:, viewport_height:, frame:)
          [
            Rectangle.new(0, 0, viewport_width, frame.y),
            Rectangle.new(0, frame.y, frame.x, frame.height),
            Rectangle.new(frame.x + frame.width, frame.y, viewport_width - frame.x - frame.width, frame.height),
            Rectangle.new(0, frame.y + frame.height, viewport_width, viewport_height - frame.y - frame.height)
          ]
        end

        def lines_for(style:, frame:, spiral_corner: "top_left")
          case style
          when "golden_ratio"
            golden_ratio_lines(x: frame.x, y: frame.y, width: frame.width, height: frame.height)
          when "golden_spiral"
            golden_spiral_lines(x: frame.x, y: frame.y, width: frame.width, height: frame.height, corner: spiral_corner)
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

        def golden_spiral_lines(x:, y:, width:, height:, corner: "top_left")
          frame = golden_spiral_frame(x: x, y: y, width: width, height: height)
          points = golden_spiral_points(frame: frame, corner: corner)
          points.each_cons(2).map do |from_point, to_point|
            Line.new(from_point[0], from_point[1], to_point[0], to_point[1])
          end
        end

        def draw(view:, frame:, style:, mask_color:, mask_alpha:, line_color:, line_width:, ratio_label: nil, style_label: nil, spiral_corner: "top_left")
          draw_masks(view, mask_rectangles(viewport_width: view.vpwidth, viewport_height: view.vpheight, frame: frame), mask_color, mask_alpha)
          draw_lines(view, lines_for(style: style, frame: frame, spiral_corner: spiral_corner), line_color, line_width)
          draw_status_label(view, frame, ratio_label, style_label, line_color)
        end

        private

        def golden_spiral_frame(x:, y:, width:, height:)
          rect_width = width.to_f
          rect_height = height.to_f

          if rect_width >= rect_height
            spiral_width = [rect_width, rect_height * GOLDEN_RATIO].min
            spiral_height = spiral_width / GOLDEN_RATIO
          else
            spiral_height = [rect_height, rect_width * GOLDEN_RATIO].min
            spiral_width = spiral_height / GOLDEN_RATIO
          end

          Rectangle.new(
            x + ((rect_width - spiral_width) / 2.0),
            y + ((rect_height - spiral_height) / 2.0),
            spiral_width,
            spiral_height
          )
        end

        def golden_spiral_points(frame:, corner:)
          if frame.width >= frame.height
            landscape_spiral_points(width: frame.width, height: frame.height, corner: corner).map do |point_x, point_y|
              [point_x + frame.x, point_y + frame.y]
            end
          else
            rotated_corner = rotated_corner_for_portrait(corner)
            rotated_points = landscape_spiral_points(
              width: frame.height,
              height: frame.width,
              corner: rotated_corner
            )

            rotated_points.map do |point_x, point_y|
              [
                frame.x + point_y,
                frame.y + (frame.height - point_x)
              ]
            end
          end
        end

        def landscape_spiral_points(width:, height:, corner:)
          anchor_points = landscape_base_spiral_points(width: width, height: height)
          focus = landscape_spiral_focus(width: width, height: height)
          transformed_points, transformed_focus = transform_spiral_geometry(
            points: anchor_points,
            focus: focus,
            width: width,
            height: height,
            corner: corner
          )

          smooth_spiral_points(points: transformed_points, focus: transformed_focus)
        end

        def landscape_base_spiral_points(width:, height:)
          remaining = Rectangle.new(0.0, 0.0, width.to_f, height.to_f)
          side_sequence = %i[left top right bottom]
          points = []
          step_index = 0

          while remaining.width > 1.0 && remaining.height > 1.0 && step_index < 12
            side = side_sequence[step_index % side_sequence.length]
            square = spiral_square(remaining, side)
            arc_points = quarter_arc_points(square: square, side: side)
            points.concat(points.empty? ? arc_points : arc_points.drop(1))
            remaining = remaining_spiral_rect(remaining, side, square.width)
            step_index += 1
          end

          points
        end

        def landscape_spiral_focus(width:, height:)
          remaining = Rectangle.new(0.0, 0.0, width.to_f, height.to_f)
          side_sequence = %i[left top right bottom]
          step_index = 0

          while remaining.width > 0.01 && remaining.height > 0.01 && step_index < 24
            side = side_sequence[step_index % side_sequence.length]
            square = spiral_square(remaining, side)
            remaining = remaining_spiral_rect(remaining, side, square.width)
            step_index += 1
          end

          [remaining.x + (remaining.width / 2.0), remaining.y + (remaining.height / 2.0)]
        end

        def transform_spiral_geometry(points:, focus:, width:, height:, corner:)
          transformed_points = case corner
                               when "bottom_left"
                                 points.map { |point_x, point_y| [width - point_x, point_y] }
                               when "top_right"
                                 points.map { |point_x, point_y| [point_x, height - point_y] }
                               when "top_left"
                                 points.map { |point_x, point_y| [width - point_x, height - point_y] }
                               else
                                 points
                               end

          transformed_focus = case corner
                              when "bottom_left"
                                [width - focus[0], focus[1]]
                              when "top_right"
                                [focus[0], height - focus[1]]
                              when "top_left"
                                [width - focus[0], height - focus[1]]
                              else
                                focus
                              end

          [transformed_points, transformed_focus]
        end

        def smooth_spiral_points(points:, focus:)
          angles = unwrap_spiral_angles(points: points, focus: focus)
          radii = points.map do |point_x, point_y|
            Math.sqrt(((point_x - focus[0])**2) + ((point_y - focus[1])**2))
          end
          direction = angles.last >= angles.first ? 1.0 : -1.0
          slope = -direction * GOLDEN_SPIRAL_RATE
          intercept = Math.log(radii.first) - (slope * angles.first)
          theta_start = angles.first
          theta_end = angles.last

          (0..SMOOTH_SPIRAL_SEGMENTS).map do |step|
            theta = theta_start + ((theta_end - theta_start) * (step.to_f / SMOOTH_SPIRAL_SEGMENTS))
            radius = Math.exp(intercept + (slope * theta))
            [
              (focus[0] + (Math.cos(theta) * radius)).round(2),
              (focus[1] + (Math.sin(theta) * radius)).round(2)
            ]
          end
        end

        def unwrap_spiral_angles(points:, focus:)
          raw_angles = points.map do |point_x, point_y|
            Math.atan2(point_y - focus[1], point_x - focus[0])
          end

          raw_angles.each_with_object([]) do |angle, memo|
            if memo.empty?
              memo << angle
              next
            end

            adjusted = angle
            adjusted += (2.0 * Math::PI) while adjusted - memo.last < -Math::PI
            adjusted -= (2.0 * Math::PI) while adjusted - memo.last > Math::PI
            memo << adjusted
          end
        end

        def spiral_square(rect, side)
          size = [rect.width, rect.height].min

          case side
          when :left, :top
            Rectangle.new(rect.x, rect.y, size, size)
          when :right
            Rectangle.new(rect.x + rect.width - size, rect.y, size, size)
          when :bottom
            Rectangle.new(rect.x, rect.y + rect.height - size, size, size)
          end
        end

        def remaining_spiral_rect(rect, side, size)
          case side
          when :left
            Rectangle.new(rect.x + size, rect.y, rect.width - size, rect.height)
          when :top
            Rectangle.new(rect.x, rect.y + size, rect.width, rect.height - size)
          when :right
            Rectangle.new(rect.x, rect.y, rect.width - size, rect.height)
          when :bottom
            Rectangle.new(rect.x, rect.y, rect.width, rect.height - size)
          end
        end

        def quarter_arc_points(square:, side:)
          center_x, center_y, start_angle, end_angle = quarter_arc_definition(square, side)
          radius = square.width

          (0..GOLDEN_SPIRAL_SEGMENTS).map do |step|
            angle = start_angle + ((end_angle - start_angle) * (step.to_f / GOLDEN_SPIRAL_SEGMENTS))
            radians = angle * Math::PI / 180.0
            [
              (center_x + (Math.cos(radians) * radius)).round(2),
              (center_y + (Math.sin(radians) * radius)).round(2)
            ]
          end
        end

        def quarter_arc_definition(square, side)
          case side
          when :left
            [square.x, square.y, 90.0, 0.0]
          when :top
            [square.x + square.width, square.y, 180.0, 90.0]
          when :right
            [square.x + square.width, square.y + square.height, 270.0, 180.0]
          when :bottom
            [square.x, square.y + square.height, 0.0, -90.0]
          end
        end

        def rotated_corner_for_portrait(corner)
          {
            "top_left" => "top_right",
            "top_right" => "bottom_right",
            "bottom_right" => "bottom_left",
            "bottom_left" => "top_left"
          }.fetch(corner, "top_right")
        end

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

        def draw_status_label(view, frame, ratio_label, style_label, line_color)
          return if ratio_label.nil? && style_label.nil?

          label = [ratio_label, style_label].compact.join(" · ")
          view.drawing_color = color_for(line_color, 255)
          view.draw_text(
            Geom::Point3d.new(frame.x + 16, frame.y + 16, 0),
            label,
            pixel_size: 18,
            bold: true
          )
        rescue StandardError
          nil
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
