class CreateFogArea
  include Interactor

  def call
    context.fog_area = context.map.fog_areas.create(context.fog_area_params)

    return if context.fog_area.persisted?

    context.fail!
  end
end
