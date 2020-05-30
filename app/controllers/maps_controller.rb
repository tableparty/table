class MapsController < ApplicationController
  before_action :require_login

  def new
    respond_to :js

    campaign = current_user.campaigns.find(params[:campaign_id])

    render layout: "modal", locals: {
      map: campaign.maps.new
    }
  end

  def create
    campaign = current_user.campaigns.find(params[:campaign_id])
    map = campaign.maps.new(map_params)
    if map.save
      map.center_image
      map.populate_characters
      campaign.update(current_map: map)
      CampaignChannel.broadcast_current_map(campaign)
      CampaignChannel.broadcast_map_selector(campaign)
      head :ok
    else
      render partial: "form", locals: { map: map }, status: :bad_request
    end
  end

  def destroy
    map = current_user.maps.find(params[:id])
    if map.destroy
      redirect_to campaign, success: "Map successfully deleted."
    else
      redirect_to campaign, failure: "Map could not be deleted."
    end
  end

  private

  def map_params
    params.require(:map).permit(:name, :image, :grid_size)
  end
end
