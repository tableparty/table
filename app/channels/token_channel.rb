class TokenChannel < ApplicationCable::Channel
  def subscribed
    token = Token.find(params[:id])
    stream_for token
  end

  def move(data)
    token = Token.find(data["id"])
    return if token.x == data["x"] && token.y == data["y"]

    token.update(x: data["x"], y: data["y"])
    broadcast_to(
      token,
      {
        operator: data["operator"],
        x: token.x,
        y: token.y
      }
    )
  end
end
