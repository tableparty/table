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

  def edit
    respond_to :js

    map = current_user.maps.find(params[:map_id])
    token = map.tokens.find(params[:id])

    render layout: "modal", locals: { token: token }
  end

  def update
    map = current_user.maps.find(params[:map_id])
    token = map.tokens.find(params[:id])
    if token.update(token_params)
      TokenUpdateBroadcastJob.perform_later(token)
      head :ok
    else
      render(
        partial: "form",
        locals: { token: token },
        status: :bad_request
      )
    end
  end

  private

  def token_params
    params.require(:token).permit(
      :name,
      :image,
      :identifier,
      :size,
      :token_template_id
    )
  end
end
