require "rails_helper"

RSpec.describe FogFeature do
  describe ".enabled_for?" do
    it "is enabled for John" do
      user = build :user, email: "jdbann@icloud.com"
      expect(described_class.enabled_for?(user)).to eq true
    end

    it "is not enabled for others" do
      user = build :user
      expect(described_class.enabled_for?(user)).to eq false
    end
  end
end
