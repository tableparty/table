class TokenBroadcastJob < ApplicationJob
  queue_as :default

  def perform(token)
    MapChannel.add_token(token)
  end
end
