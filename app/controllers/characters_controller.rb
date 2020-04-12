class CharactersController < ApplicationController
  before_action :require_login

  def new
    campaign = current_user.campaigns.find(params[:campaign_id])
    render locals: { character: campaign.characters.new }
  end

  def create
    campaign = current_user.campaigns.find(params[:campaign_id])
    character = campaign.characters.new(character_params)
    if character.save
      campaign.populate_tokens
      redirect_to campaign
    else
      render :new, locals: { character: character }
    end
  end

  def edit
    campaign = current_user.campaigns.find(params[:campaign_id])
    character = campaign.characters.find(params[:id])
    render locals: { character: character }
  end

  def update
    campaign = current_user.campaigns.find(params[:campaign_id])
    character = campaign.characters.find(params[:id])
    if character.update(character_params)
      redirect_to campaign, success: "Character successfully updated."
    else
      render :edit, locals: { character: character }
    end
  end

  def destroy
    campaign = current_user.campaigns.find(params[:campaign_id])
    character = campaign.characters.find(params[:id])
    if character.destroy
      redirect_to campaign, success: "Character successfully deleted."
    else
      redirect_to edit_campaign_character_path(campaign, character)
    end
  end

  private

  def character_params
    params.require(:character).permit(:name, :image)
  end
end
