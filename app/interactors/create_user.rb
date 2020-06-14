class CreateUser
  include Interactor::Organizer

  organize ValidateSponsorCode, SaveUser
end
