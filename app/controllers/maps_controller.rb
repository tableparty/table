class MapsController < ApplicationController
  def new
    campaign = Campaign.find(params[:campaign_id])
    render locals: { map: campaign.maps.new }
  end

  def create
    campaign = Campaign.find(params[:campaign_id])
    map = campaign.maps.new(map_params)
    if map.save
      redirect_to campaign
    else
      render :new, locals: { map: map }
    end
  end

  private

  def map_params
    params.require(:map).permit(:name)
  end
end
