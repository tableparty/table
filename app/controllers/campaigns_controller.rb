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
    render locals: { campaign: Campaign.find(params[:id]) }, layout: "campaign"
  end

  private

  def campaign_params
    params.require(:campaign).permit(:name)
  end
end
