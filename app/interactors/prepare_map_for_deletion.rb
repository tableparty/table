class PrepareMapForDeletion
  include Interactor

  def call
    if context.campaign.current_map == context.map
      result = ChangeCurrentMap.call(campaign: context.campaign, map: nil)
      if !result.success?
        context.fail!
      end
    end
  end
end
