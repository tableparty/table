class TokenBroadcastJob < ApplicationJob
  queue_as :default

  def perform(token)
    Maps::TokensChannel.add_token(token)
  end
end
