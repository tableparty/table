class MapChannel < ApplicationCable::Channel
  def subscribed
    map = Map.find(params[:id])
    stream_for map
  end

  def move_map(data)
    map = Map.find(data["map_id"])
    return if map.x == data["x"] && map.y == data["y"]

    if map.update(x: data["x"], y: data["y"])
      broadcast_to(
        map,
        {
          operation: "move",
          x: map.x,
          y: map.y
        }
      )
    end
  end

  def set_zoom(data)
    map = Map.find(data["map_id"])
    return if map.zoom == data["zoom"]

    if map.update(zoom: data["zoom"])
      broadcast_to(
        map,
        {
          operation: "zoom",
          zoom: map.zoom,
          width: map.width,
          height: map.height,
          x: map.x,
          y: map.y
        }
      )
    end
  end
end
