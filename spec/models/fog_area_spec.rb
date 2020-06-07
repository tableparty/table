require "rails_helper"

RSpec.describe FogArea, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:map) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of :map }
    it { is_expected.to validate_presence_of :path }
    it { is_expected.to allow_value("M -10 10 L 8 400 Z").for(:path) }
    it { is_expected.not_to allow_value("horses").for(:path) }
  end
end
