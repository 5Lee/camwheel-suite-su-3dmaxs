# frozen_string_literal: true

constants_file = File.join(__dir__, "..", "constants")
settings_store_file = File.join(__dir__, "..", "data", "settings_store")

if defined?(Sketchup)
  Sketchup.require(constants_file)
  Sketchup.require(settings_store_file)
else
  require constants_file
  require settings_store_file
end

module CamWheel
  module Services
    class CameraService
      class << self
        def exit_distance(spans:, safety_offset:)
          spans.first.last + safety_offset
        end

        def ray_box_exit_distance(origin:, direction:, min_corner:, max_corner:)
          t_min = -Float::INFINITY
          t_max = Float::INFINITY

          3.times do |index|
            axis_origin = origin[index].to_f
            axis_direction = direction[index].to_f
            axis_min = min_corner[index].to_f
            axis_max = max_corner[index].to_f

            if axis_direction.zero?
              return nil if axis_origin < axis_min || axis_origin > axis_max

              next
            end

            first_hit = (axis_min - axis_origin) / axis_direction
            second_hit = (axis_max - axis_origin) / axis_direction
            near_hit, far_hit = [first_hit, second_hit].minmax

            t_min = [t_min, near_hit].max
            t_max = [t_max, far_hit].min

            return nil if t_min > t_max
          end

          t_max.negative? ? nil : t_max
        end

        def stable_up_vector_components(normal:)
          normalized = normalize_array(normal)
          world_up = [0.0, 0.0, 1.0]
          alignment = dot(normalized, world_up).abs

          alignment > 0.99 ? [0.0, 1.0, 0.0] : world_up
        end

        def view_direction_for_normal(normal:, current_direction: nil)
          normalized_normal = normalize_array(normal)
          return normalized_normal if current_direction && dot(normalized_normal, normalize_array(current_direction)) >= 0.0

          normalized_normal.map { |component| -component }
        end

        def alignment_distance(eye:, point:)
          distance(eye, point)
        end

        def align_view(view:, point:, normal:, distance: nil, enable_two_point_perspective: true)
          return nil unless defined?(Sketchup)

          camera = view.camera
          current_direction = vector_to_a(camera.target - camera.eye)
          direction = view_direction_for_normal(normal: vector_to_a(normal), current_direction: current_direction)
          up_components = stable_up_vector_components(normal: vector_to_a(normal))
          view_distance = distance || alignment_distance(eye: point_to_a(camera.eye), point: point_to_a(point))

          eye = point.offset(Geom::Vector3d.new(
                               -direction[0] * view_distance,
                               -direction[1] * view_distance,
                               -direction[2] * view_distance
                             ))
          up = Geom::Vector3d.new(*up_components)

          view.camera.set(eye, point, up)
          view.invalidate
          enable_two_point_perspective!(view) if enable_two_point_perspective
          true
        end

        def penetrate_active_view(view:, safety_offset:)
          return nil unless defined?(Sketchup)

          camera = view.camera
          origin = point_to_a(camera.eye)
          direction = normalize_array(vector_to_a(camera.target - camera.eye))
          ray = [camera.eye, Geom::Vector3d.new(*direction)]
          hit = view.model.raytest(ray, false)
          return nil unless hit

          hit_point, path = hit
          entry_distance = distance(origin, point_to_a(hit_point))
          bounds = world_bounds_for(path)
          return shift_camera(view, direction, entry_distance + safety_offset) unless bounds

          exit_hit = ray_box_exit_distance(
            origin: origin,
            direction: direction,
            min_corner: point_to_a(bounds.min),
            max_corner: point_to_a(bounds.max)
          )

          final_distance = exit_distance(
            spans: [[entry_distance, exit_hit || entry_distance]],
            safety_offset: safety_offset
          )

          shift_camera(view, direction, final_distance)
        end

        private

        def shift_camera(view, direction, distance_value)
          camera = view.camera
          offset = Geom::Vector3d.new(
            direction[0] * distance_value,
            direction[1] * distance_value,
            direction[2] * distance_value
          )
          new_eye = camera.eye.offset(offset)
          new_target = camera.target.offset(offset)
          camera.set(new_eye, new_target, camera.up)
          view.invalidate
          distance_value
        end

        def world_bounds_for(path)
          return nil if path.nil? || path.empty?

          if defined?(Sketchup::InstancePath)
            Sketchup::InstancePath.new(path).bounds
          else
            path.last.bounds
          end
        rescue StandardError
          path.last.bounds
        end

        def normalize_array(vector)
          length = Math.sqrt(dot(vector, vector))
          return [1.0, 0.0, 0.0] if length.zero?

          vector.map { |component| component.to_f / length }
        end

        def dot(left, right)
          left.zip(right).sum { |first, second| first.to_f * second.to_f }
        end

        def distance(first, second)
          Math.sqrt(
            ((first[0] - second[0])**2) +
            ((first[1] - second[1])**2) +
            ((first[2] - second[2])**2)
          )
        end

        def point_to_a(point)
          [point.x.to_f, point.y.to_f, point.z.to_f]
        end

        def vector_to_a(vector)
          [vector.x.to_f, vector.y.to_f, vector.z.to_f]
        end

        def default_view_distance(view)
          camera = view.camera
          distance(point_to_a(camera.eye), point_to_a(camera.target))
        end

        def enable_two_point_perspective!(view)
          return unless defined?(Sketchup)

          if view.camera.respond_to?(:perspective=)
            view.camera.perspective = true
          end

          Sketchup.send_action("viewTwoPointPerspective:") if Sketchup.respond_to?(:send_action)
        rescue StandardError
          nil
        end
      end
    end
  end
end
