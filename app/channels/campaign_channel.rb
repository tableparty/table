class CampaignChannel < ApplicationCable::Channel
  def subscribed
    campaign = Campaign.find(params[:id])
    stream_for campaign
  end

  def change_current_map(data)
    campaign = Campaign.find(data["campaign_id"])
    map = campaign.maps.find(data["map_id"])
    return if campaign.current_map == map

    campaign.update(current_map: map)
    broadcast_to(
      campaign,
      current_map_html: render_current_map(campaign)
    )
  end

  private

  def render_current_map(campaign)
    ApplicationController.renderer.render(
      partial: "campaigns/current_map",
      locals: { campaign: campaign }
    )
  end
end
