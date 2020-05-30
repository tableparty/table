class UpdateMap
  include Interactor::Organizer

  organize SaveMap, BroadcastCurrentMap, BroadcastMapSelector
end
