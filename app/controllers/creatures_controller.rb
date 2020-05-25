class CreaturesController < ApplicationController
  before_action :require_login

  def create
    creature = campaign.creatures.new(creature_params)
    if creature.save
      campaign.current_map.tokens.create(token_template: creature)
      head :ok
    else
      render(
        partial: "form",
        locals: { creature: creature },
        status: :bad_request
      )
    end
  end

  def edit
    respond_to :js

    creature = campaign.creatures.find(params[:id])
    render layout: "modal", locals: { creature: creature }
  end

  def update
    creature = campaign.creatures.find(params[:id])
    if creature.update(creature_params)
      head :ok
    else
      render(
        partial: "form",
        locals: { creature: creature },
        status: :bad_request
      )
    end
  end

  def destroy
    creature = campaign.creatures.find(params[:id])
    if creature.destroy
      redirect_to campaign, success: "Creature successfully deleted."
    else
      redirect_to edit_campaign_creature_path(campaign, creature)
    end
  end

  private

  def campaign
    current_user.campaigns.find(params[:campaign_id])
  end

  def creature_params
    params.require(:creature).permit(:name, :image, :size)
  end
end
