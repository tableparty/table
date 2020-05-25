class UsersController < Clearance::UsersController
  def create
    @user = user_from_params

    if sign_up_code_correct && @user.save
      sign_in @user
      redirect_back_or url_after_create
    else
      render template: "users/new"
    end
  end

  private

  def user_params
    params[:user].permit(:email, :password, :name)
  end

  def sign_up_code_correct
    params[:sign_up_code] == ENV["SIGN_UP_CODE"]
  end
end
