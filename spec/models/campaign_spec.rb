require "rails_helper"

RSpec.describe Campaign, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:maps).dependent(:destroy) }
    it { is_expected.to belong_to(:current_map).optional(true) }
    it { is_expected.to belong_to(:user).required(true) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of :name }
  end
end
