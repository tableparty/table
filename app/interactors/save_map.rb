class SaveMap
  include Interactor

  def call
    if !context.map.update(context.map_params)
      context.fail!
    end
  end
end
