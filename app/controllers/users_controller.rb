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
    if params[:user]
      params[:user].permit(:email, :password, :name)
    else
      Hash.new
    end
  end

  def sign_up_code_correct
    params[:sign_up_code] == ENV["SIGN_UP_CODE"]
  end

  def url_after_create
    campaigns_url
  end

  def redirect_signed_in_users
    if signed_in?
      redirect_to campaigns_url
    end
  end
end
