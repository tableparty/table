class TokenUpdateBroadcastJob < ApplicationJob
  queue_as :default

  def perform(token)
    Maps::TokensChannel.update_token(token)
  end
end
