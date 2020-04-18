class TokensController < ApplicationController
  before_action :require_login

  def new
    map = current_user.maps.find(params[:map_id])
    render locals: { token: map.tokens.build }
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
    params.require(:token).permit(:name, :image)
  end
end
