class ValidateSponsorCode
  include Interactor
  include ApplicationHelper

  def call
    if context.sponsor_code != ENV["SIGN_UP_CODE"]
      context.fail!(message: I18n.t(
        "incorrect_sponsor_code_html",
        support_email: support_email,
        patreon_url: patreon_url
      ).html_safe)
    end
  end
end
