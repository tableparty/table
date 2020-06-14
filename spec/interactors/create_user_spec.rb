require "rails_helper"

describe CreateUser do
  it "organizes flow of interactors to create a user" do
    expect(described_class.organized).to eq(
      [
        ValidateSponsorCode,
        SaveUser
      ]
    )
  end
end
