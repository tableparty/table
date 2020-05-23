class MapsController < ApplicationController
  before_action :require_login

  def new
    campaign = current_user.campaigns.find(params[:campaign_id])
    render locals: { map: campaign.maps.new }
  end

  def create
    campaign = current_user.campaigns.find(params[:campaign_id])
    map = campaign.maps.new(map_params)
    if map.save
      map.center_image
      map.populate_characters
      redirect_to campaign
    else
      render :new, locals: { map: map }
    end
  end

  private

  def map_params
    params.require(:map).permit(:name, :image, :grid_size)
  end
end
