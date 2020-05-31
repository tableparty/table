class SetupMap
  include Interactor

  def call
    context.map.center_image
    context.map.populate_characters
  end
end
