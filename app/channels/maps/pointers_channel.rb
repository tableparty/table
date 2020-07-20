module Maps
  class PointersChannel < ApplicationCable::Channel
    def subscribed
      map = Map.find(params[:id])
      stream_for map
    end

    def point_to(data)
      map = Map.find(data["map_id"])
      pointer = Pointer.new(map: map, x: data["x"], y: data["y"])

      Maps::PointersChannel.add_pointer(pointer)
    end

    class << self
      def add_pointer(pointer)
        broadcast_to(
          pointer.map,
          {
            operation: "addPointer",
            pointer_html: render_pointer(pointer)
          }
        )
      end

      private

      def render_pointer(pointer)
        ApplicationController.renderer.render(
          partial: "pointers/pointer",
          locals: { pointer: pointer }
        )
      end
    end
  end
end
