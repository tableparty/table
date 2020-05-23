class SessionsController < Clearance::SessionsController
  private

  def url_after_create
    campaigns_url
  end

  def url_for_signed_in_users
    campaigns_url
  end
end
