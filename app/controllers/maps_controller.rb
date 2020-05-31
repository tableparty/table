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

  private

  def map_params
    params.require(:map).permit(:name, :image, :grid_size)
  end
end
