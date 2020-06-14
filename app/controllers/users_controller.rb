class UsersController < Clearance::UsersController
  def create
    @user = user_from_params
    result = CreateUser.call(sponsor_code: params[:sign_up_code], user: @user)

    if result.success?
      sign_in @user
      redirect_back_or url_after_create
    else
      flash.now[:error] = result.message
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

  def url_after_create
    campaigns_url
  end

  def redirect_signed_in_users
    if signed_in?
      redirect_to campaigns_url
    end
  end
end
