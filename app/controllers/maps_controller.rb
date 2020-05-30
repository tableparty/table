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
    result = CreateNewMap.call(campaign: campaign, map_params: map_params)
    if result.success?
      head :ok
    else
      render partial: "form", locals: { map: result.map }, status: :bad_request
    end
  end

  def edit
    respond_to :js

    map = current_user.maps.find(params[:id])
    render layout: "modal", locals: { map: map }
  end

  def update
    map = current_user.maps.find(params[:id])
    result = UpdateMap.call(
      campaign: map.campaign,
      map: map,
      map_params: map_params
    )
    if result.success?
      head :ok
    else
      render partial: "form", locals: { map: map }, status: :bad_request
    end
  end

  def destroy
    map = current_user.maps.find(params[:id])
    result = DeleteMap.call(campaign: map.campaign, map: map)
    if result.success?
      head :ok
    else
      head :bad_request
    end
  end

  private

  def map_params
    params.require(:map).permit(:name, :image, :grid_size)
  end
end
