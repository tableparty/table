class ChangeCurrentMap
  include Interactor::Organizer

  organize SetCurrentMap, BroadcastCurrentMap
end
