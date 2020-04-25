class CharactersController < ApplicationController
  before_action :require_login

  def create
    character = campaign.characters.new(character_params)
    if character.save
      campaign.populate_characters
      head :ok
    else
      render(
        partial: "form",
        locals: { character: character },
        status: :bad_request
      )
    end
  end

  def edit
    respond_to :js

    character = campaign.characters.find(params[:id])
    render layout: "modal", locals: { character: character }
  end

  def update
    character = campaign.characters.find(params[:id])
    if character.update(character_params)
      head :ok
    else
      render(
        partial: "form",
        locals: { character: character },
        status: :bad_request
      )
    end
  end

  def destroy
    character = campaign.characters.find(params[:id])
    if character.destroy
      redirect_to campaign, success: "Character successfully deleted."
    else
      redirect_to edit_campaign_character_path(campaign, character)
    end
  end

  private

  def campaign
    current_user.campaigns.find(params[:campaign_id])
  end

  def character_params
    params.require(:character).permit(:name, :image)
  end
end
