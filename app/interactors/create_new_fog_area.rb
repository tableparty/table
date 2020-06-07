class CreateNewFogArea
  include Interactor::Organizer

  organize(
    CreateFogArea,
    BroadcastFogArea
  )
end
