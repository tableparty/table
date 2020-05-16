class CampaignChannel < ApplicationCable::Channel
  def subscribed
    campaign = Campaign.find(params[:id])
    stream_for campaign
  end

  def change_current_map(data)
    campaign = Campaign.find(data["campaign_id"])
    map = campaign.maps.find(data["map_id"])
    return if !dm?(campaign) || campaign.current_map == map

    campaign.update(current_map: map)
    broadcast_to(
      campaign,
      operation: "change_current_map"
    )
  end
end
