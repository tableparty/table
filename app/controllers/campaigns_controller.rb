class CampaignsController < ApplicationController
  before_action :require_login, except: [:show]

  def index
    render locals: { campaigns: current_user.campaigns }
  end

  def new
    render locals: { campaign: Campaign.new }
  end

  def create
    campaign = current_user.campaigns.new(campaign_params)
    if campaign.save
      redirect_to campaign
    else
      render :new, locals: { campaign: campaign }
    end
  end

  def show
    campaign = Campaign.find(params[:id])
    if request.xhr?
      render json: {
        html: render_to_string(
          partial: "campaigns/current_map",
          locals: { campaign: campaign }
        )
      }
    else
      render locals: { campaign: campaign }, layout: "campaign"
    end
  end

  private

  def campaign_params
    params.require(:campaign).permit(:name)
  end
end
