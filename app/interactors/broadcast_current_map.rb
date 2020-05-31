class BroadcastCurrentMap
  include Interactor

  def call
    CampaignChannel.broadcast_current_map(context.campaign)
  end
end
