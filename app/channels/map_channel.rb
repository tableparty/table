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

  def stash_token(data)
    map = Map.find(data["map_id"])
    token = map.tokens.find(data["token_id"])
    return if !dm?(map.campaign)

    token.update(stashed: true)
    broadcast_to(
      map,
      {
        operation: "stashToken",
        token_id: token.id,
        stashed: true
      }
    )
  end

  def place_token(data)
    map = Map.find(data["map_id"])
    token = map.tokens.find(data["token_id"])
    return if !dm?(map.campaign)

    if token.copy_on_place?
      map.copy_token(token)
    else
      token.update(stashed: false)
      MapChannel.add_token(token)
    end
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

    def add_token(token)
      broadcast_to(
        token.map,
        {
          operation: "addToken",
          token_id: token.id,
          token_html: render_token(token),
          x: token.x,
          y: token.y,
          stashed: token.stashed
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

    def render_token(token)
      ApplicationController.renderer.render(
        partial: "tokens/token",
        locals: { token: token }
      )
    end
  end
end
