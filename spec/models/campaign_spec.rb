require "rails_helper"

RSpec.describe Campaign, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:maps).dependent(:destroy) }
    it { is_expected.to belong_to(:current_map).optional(true) }
    it { is_expected.to belong_to(:user).required(true) }
    it { is_expected.to have_many(:characters).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of :name }
  end

  describe "populate_tokens" do
    it "populates the tokens for the campaign's maps" do
      map = create(:map)
      campaign = map.campaign
      create(:character, campaign: campaign)

      campaign.populate_tokens

      expect(map.tokens).to be_present
    end
  end
end
