class SaveUser
  include Interactor

  def call
    if !context.user.save
      context.fail!(message: "Error saving user")
    end
  end
end
