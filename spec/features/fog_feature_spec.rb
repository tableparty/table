require "rails_helper"

RSpec.describe FogFeature do
  describe ".enabled_for?" do
    it "is enabled for John" do
      user = build :user, email: "jdbann@icloud.com"
      expect(described_class.enabled_for?(user)).to eq true
    end

    it "is not enabled for others if FEATURE_FOG_ENABLED is not true" do
      original_value = ENV["FEATURE_FOG_ENABLED"]
      ENV["FEATURE_FOG_ENABLED"] = nil
      user = build :user
      expect(described_class.enabled_for?(user)).to eq false
      ENV["FEATURE_FOG_ENABLED"] = original_value
    end

    it "is enabled for others if FEATURE_FOG_ENABLED is true" do
      original_value = ENV["FEATURE_FOG_ENABLED"]
      ENV["FEATURE_FOG_ENABLED"] = "true"
      user = build :user
      expect(described_class.enabled_for?(user)).to eq true
      ENV["FEATURE_FOG_ENABLED"] = original_value
    end
  end
end
