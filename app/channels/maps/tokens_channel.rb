module Maps
  class TokensChannel < ApplicationCable::Channel
    def subscribed
      map = Map.find(params[:id])
      stream_for map
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
        Maps::TokensChannel.add_token(token)
      end
    end

    def delete_token(data)
      map = Map.find(data["map_id"])
      token = map.tokens.find(data["token_id"])
      return if !dm?(map.campaign)

      token.destroy
      broadcast_to(
        map,
        {
          operation: "deleteToken",
          token_id: token.id
        }
      )
    end

    class << self
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

      def update_token(token)
        broadcast_to(
          token.map,
          {
            operation: "updateToken",
            token_id: token.id,
            token_html: render_token(token),
            x: token.x,
            y: token.y,
            stashed: token.stashed
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
end
