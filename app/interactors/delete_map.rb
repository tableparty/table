class DeleteMap
  include Interactor::Organizer

  organize PrepareMapForDeletion, DestroyMap, BroadcastMapSelector
end
