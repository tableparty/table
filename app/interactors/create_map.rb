class CreateMap
  include Interactor

  def call
    context.map = context.campaign.maps.create(context.map_params)
    if !context.map.persisted?
      context.fail!
    end
  end
end
