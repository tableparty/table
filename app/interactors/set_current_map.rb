class SetCurrentMap
  include Interactor

  def call
    if !context.campaign.update(current_map: context.map)
      context.fail!
    end
  end
end
