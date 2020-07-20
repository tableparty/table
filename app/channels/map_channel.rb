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

  def point_to(data)
    map = Map.find(data["map_id"])
    pointer = Pointer.new(map: map, x: data["x"], y: data["y"])

    MapChannel.add_pointer(pointer)
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
