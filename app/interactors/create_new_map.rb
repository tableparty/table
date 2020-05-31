class CreateNewMap
  include Interactor::Organizer

  organize(
    CreateMap,
    SetupMap,
    ChangeCurrentMap,
    BroadcastCurrentMap,
    BroadcastMapSelector
  )
end
