class MapChannel < ApplicationCable::Channel
  def subscribed
    map = Map.find(params[:id])
    stream_for map
  end

  def move_map(data)
    map = Map.find(data["map_id"])
    return if !dm?(map.campaign) || map.x == data["x"] && map.y == data["y"]

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
    return if !dm?(map.campaign) || map.zoom == data["zoom"]

    if map.update(zoom: data["zoom"])
      broadcast_to(
        map,
        {
          operation: "zoom",
          zoom: map.zoom,
          zoomAmount: map.zoom_amount,
          width: map.width,
          height: map.height,
          x: map.x,
          y: map.y
        }
      )
    end
  end

  def move_token(data)
    map = Map.find(data["map_id"])
    token = map.tokens.find(data["token_id"])
    return if token.x == data["x"] && token.y == data["y"]

    token.update(x: data["x"], y: data["y"])
    broadcast_to(
      map,
      {
        operation: "moveToken",
        token_id: token.id,
        x: token.x,
        y: token.y
      }
    )
  end

  class << self
    def add_token(token)
      broadcast_to(
        token.map,
        {
          operation: "addToken",
          token_html: render_token(token),
          x: token.x,
          y: token.y
        }
      )
    end

    private

    def render_token(token)
      ApplicationController.renderer.render(
        partial: "tokens/token",
        locals: { token: token }
      )
    end
  end
end
