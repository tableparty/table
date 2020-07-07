class FogFeature
  class << self
    def enabled_for?(user)
      user.email == "jdbann@icloud.com" ||
        ENV.fetch("FEATURE_FOG_ENABLED", false) == "true"
    end
  end
end
