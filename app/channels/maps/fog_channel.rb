module Maps
  class FogChannel < ApplicationCable::Channel
    def subscribed
      map = Map.find(params[:id])
      stream_for [map, :fog]
    end

    def reveal_area(data)
      map = Map.find(data["map_id"])

      CreateNewFogArea.call(map: map, fog_area_params: data.slice("id", "path"))
    end

    class << self
      def reveal_area(fog_area)
        broadcast_to(
          [fog_area.map, :fog],
          {
            operation: "revealArea",
            id: fog_area.id,
            path: fog_area.path
          }
        )
      end
    end
  end
end
