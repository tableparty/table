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

  def edit
    respond_to :js

    map = current_user.maps.find(params[:id])
    render layout: "modal", locals: { map: map }
  end

  def update
    map = current_user.maps.find(params[:id])
    if map.update(map_params)
      CampaignChannel.broadcast_map_selector(map.campaign)
      if map.campaign.current_map == map
        CampaignChannel.broadcast_current_map(campaign)
      end
      head :ok
    else
      render(
        partial: "form",
        locals: { map: map },
        status: :bad_request
      )
    end
  end

  def destroy
    map = current_user.maps.find(params[:id])
    if map.campaign.current_map == map
      map.campaign.update(current_map: nil)
      CampaignChannel.broadcast_current_map(map.campaign)
    end
    if map.destroy
      CampaignChannel.broadcast_map_selector(map.campaign)
      head :ok
    else
      head :bad_request
    end
  end

  private

  def map_params
    params.require(:map).permit(:name, :image, :grid_size)
  end

  def map_model_for_form(map)
    if map.persisted?
      map
    else
      [map.campaign, map]
    end
  end
  helper_method :map_model_for_form
end
