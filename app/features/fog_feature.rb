class FogFeature
  class << self
    def enabled_for?(user)
      user.email == "jdbann@icloud.com"
    end
  end
end
