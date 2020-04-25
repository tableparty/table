class TokensController < ApplicationController
  before_action :require_login

  def new
    respond_to :js

    map = current_user.maps.find(params[:map_id])
    render layout: "modal", locals: {
      character: Character.new(campaign: map.campaign),
      creature: Creature.new(campaign: map.campaign)
    }
  end

  def create
    map = current_user.maps.find(params[:map_id])
    token = map.tokens.new(token_params)
    if token.save
      redirect_to map.campaign
    else
      redirect_to map.campaign, flash: {
        error: token.errors.full_messages.to_sentence
      }
    end
  end

  private

  def token_params
    params.require(:token).permit(:name, :image, :tokenable_type, :tokenable_id)
  end
end
