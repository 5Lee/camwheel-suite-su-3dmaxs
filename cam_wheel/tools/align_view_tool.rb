# frozen_string_literal: true

camera_service_file = File.join(__dir__, "..", "services", "camera_service")
settings_store_file = File.join(__dir__, "..", "data", "settings_store")

if defined?(Sketchup)
  Sketchup.require(camera_service_file)
  Sketchup.require(settings_store_file)
else
  require camera_service_file
  require settings_store_file
end

module CamWheel
  module Tools
    class AlignViewTool
      PREVIEW_SIZE = 14

      class << self
        def preview_marker_points(screen_x:, screen_y:, size: PREVIEW_SIZE)
          half = size / 2
          [
            [screen_x - half, screen_y - half],
            [screen_x + half, screen_y - half],
            [screen_x + half, screen_y + half],
            [screen_x - half, screen_y + half]
          ]
        end
      end

      def activate
        @preview = nil
        Sketchup.status_text = "CamWheel 视角对齐：点击一个可见面"
      end

      def onLButtonDown(_flags, x, y, view)
        preview = pick_preview(view, x, y)
        return unless preview

        Services::CameraService.align_view(
          view: view,
          point: preview[:point],
          normal: preview[:normal],
          enable_two_point_perspective: Data::SettingsStore.read(:align_enable_two_point_perspective)
        )

        @preview = nil
        view.invalidate
        Sketchup.active_model.select_tool(nil)
      end

      def onMouseMove(_flags, x, y, view)
        @preview = pick_preview(view, x, y)
        view.invalidate
      end

      def onCancel(_reason, view)
        @preview = nil
        view.invalidate if view
      end

      def draw(view)
        return unless @preview

        marker_points = @preview[:polygon]
        screen_point = @preview[:screen]

        view.line_width = 2
        view.drawing_color = Sketchup::Color.new(255, 184, 77, 255)
        draw_loop(view, marker_points)

        view.drawing_color = Sketchup::Color.new(255, 255, 255, 255)
        draw_crosshair(view, screen_point)
      end

      private

      def pick_preview(view, x, y)
        pick_helper = view.pick_helper
        pick_helper.do_pick(x, y)
        face = pick_helper.picked_face
        return nil unless face

        picked_path = first_face_path(pick_helper, face)
        hit = view.model.raytest(view.pickray(x, y), false)
        return nil unless hit

        point, path = hit
        path = picked_path if picked_path

        screen = view.screen_coords(point)
        {
          point: point,
          normal: transformed_normal(face.normal, path),
          screen: [screen.x.to_i, screen.y.to_i],
          polygon: face_polygon(view, face, path)
        }
      end

      def face_polygon(view, face, path)
        points = face.outer_loop.vertices.map { |vertex| transform_point(vertex.position, path) }
        points.map do |point|
          screen_point = view.screen_coords(point)
          [screen_point.x.to_i, screen_point.y.to_i]
        end
      rescue StandardError
        self.class.preview_marker_points(screen_x: view.vpwidth / 2, screen_y: view.vpheight / 2)
      end

      def first_face_path(pick_helper, face)
        pick_helper.count.times do |index|
          next unless pick_helper.leaf_at(index) == face

          return pick_helper.path_at(index)
        end

        nil
      end

      def draw_loop(view, marker_points)
        points = marker_points.map { |x, y| Geom::Point3d.new(x, y, 0) }
        points << points.first
        view.draw2d(GL_LINE_STRIP, points)
      end

      def draw_crosshair(view, screen_point)
        x = screen_point[0]
        y = screen_point[1]
        segments = [
          Geom::Point3d.new(x - 4, y, 0),
          Geom::Point3d.new(x + 4, y, 0),
          Geom::Point3d.new(x, y - 4, 0),
          Geom::Point3d.new(x, y + 4, 0)
        ]
        view.draw2d(GL_LINES, segments)
      end

      def transformed_normal(normal, path)
        transformation = path[0...-1].reduce(Geom::Transformation.new) do |memo, entity|
          entity.respond_to?(:transformation) ? memo * entity.transformation : memo
        end

        normal.transform(transformation)
      end

      def transform_point(point, path)
        transformation = path[0...-1].reduce(Geom::Transformation.new) do |memo, entity|
          entity.respond_to?(:transformation) ? memo * entity.transformation : memo
        end

        point.transform(transformation)
      end
    end
  end
end
