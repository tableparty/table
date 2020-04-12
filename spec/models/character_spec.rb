require "rails_helper"

RSpec.describe Character, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:campaign) }
    it { is_expected.to have_one(:image_attachment) }
    it { is_expected.to have_one(:image_blob) }
    it { is_expected.to have_many(:tokens).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of :campaign }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :image }
  end
end
