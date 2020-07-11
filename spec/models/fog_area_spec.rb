require "rails_helper"

RSpec.describe FogArea, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:map) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of :map }
    it { is_expected.to validate_presence_of :path }
  end
end
