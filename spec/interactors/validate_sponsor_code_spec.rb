require "rails_helper"

describe ValidateSponsorCode do
  include ApplicationHelper

  context "when the code is correct" do
    it "succeeds the interaction" do
      result = described_class.call(sponsor_code: ENV["SIGN_UP_CODE"])

      expect(result).to be_success
      expect(result.message).to be_blank
    end
  end

  context "when the code is incorrect" do
    it "fails the interaction" do
      result = described_class.call(sponsor_code: "incorrect")

      expect(result).not_to be_success
      expect(result.message).to eq(
        I18n.t(
          "incorrect_sponsor_code_html",
          support_email: support_email,
          patreon_url: patreon_url
        ).html_safe
      )
    end
  end
end
