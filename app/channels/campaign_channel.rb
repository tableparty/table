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
    CampaignChannel.broadcast_current_map(campaign)
  end

  class << self
    def broadcast_current_map(campaign)
      broadcast_to(
        campaign,
        current_map_html: render_current_map(campaign, admin: false)
      )
      broadcast_to(
        [campaign, campaign.user],
        current_map_html: render_current_map(campaign, admin: true)
      )
    end

    def broadcast_map_selector(campaign)
      broadcast_to(
        [campaign, campaign.user],
        map_selector_html: CampaignsController.render(
          partial: "campaigns/map_selector",
          locals: { campaign: campaign }
        )
      )
    end

    private

    def render_current_map(campaign, admin: false)
      CampaignsController.render(
        partial: "campaigns/current_map",
        locals: { campaign: campaign, admin: admin }
      )
    end
  end
end
