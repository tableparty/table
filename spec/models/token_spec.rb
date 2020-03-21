require "rails_helper"

RSpec.describe Token, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:map) }
    it { is_expected.to have_one(:image_attachment) }
    it { is_expected.to have_one(:image_blob) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :image }
  end
end
