class BroadcastMapSelector
  include Interactor

  def call
    CampaignChannel.broadcast_map_selector(context.campaign)
  end
end
