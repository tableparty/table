class CampaignChannel < ApplicationCable::Channel
  def subscribed
    stream_from "campaign_#{params[:id]}"
  end

  def change_current_map(data)
    campaign = Campaign.find(data["campaign_id"])
    map = Map.find(data["map_id"])
    campaign.update(current_map: map)
    ActionCable.server.broadcast(
      "campaign_#{campaign.id}",
      campaign: campaign.attributes,
      current_map: map.attributes,
      current_map_image: Rails.application.routes.url_helpers.rails_blob_path(
        map.image,
        host: "localhost:3000"
      )
    )
  end
end
