class MapChannel < ApplicationCable::Channel
  def subscribed
    map = Map.find(params[:id])
    stream_for map
  end

  def move_map(data)
    map = Map.find(data["id"])
    return if !dm?(map.campaign) || map.x == data["x"] && map.y == data["y"]

    map.update(x: data["x"], y: data["y"])
  end

  def set_zoom(data)
    map = Map.find(data["map_id"])
    return if !dm?(map.campaign) || map.zoom == data["zoom"]

    map.update(zoom: data["zoom"])
  end
end
