class CampaignChannel < ApplicationCable::Channel
  def subscribed
    campaign = Campaign.find(params[:id])
    if dm?(campaign)
      stream_for [campaign, campaign.user]
    else
      stream_for campaign
    end
  end

  def change_current_map(data)
    campaign = Campaign.find(data["campaign_id"])
    map = campaign.maps.find(data["map_id"])
    return if !dm?(campaign) || campaign.current_map == map

    campaign.update(current_map: map)
    broadcast_to(
      campaign,
      current_map_html: render_current_map(campaign, admin: false)
    )
    broadcast_to(
      [campaign, campaign.user],
      current_map_html: render_current_map(campaign, admin: true)
    )
  end

  private

  def render_current_map(campaign, admin: false)
    render_partial(
      "campaigns/current_map",
      locals: { campaign: campaign, admin: admin }
    )
  end
end
