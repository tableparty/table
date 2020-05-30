class DestroyMap
  include Interactor

  def call
    if !context.map.destroy
      context.fail!
    end
  end
end
