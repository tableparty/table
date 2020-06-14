require "rails_helper"

describe SaveUser do
  context "when saving succeeds" do
    it "saves the users in the context" do
      user = instance_double(User, save: true)

      result = described_class.call(user: user)

      expect(result).to be_success
      expect(user).to have_received(:save)
      expect(result.user).to eq user
    end

    it "does not add an error message" do
      user = instance_double(User, save: true)

      result = described_class.call(user: user)

      expect(result.message).to be_blank
    end
  end

  describe "when saving fails" do
    it "fails the interaction" do
      user = instance_double(User, save: false)

      result = described_class.call(user: user)

      expect(result).not_to be_success
      expect(user).to have_received(:save)
      expect(result.user).to eq user
    end

    it "adds an error message" do
      user = instance_double(User, save: false)

      result = described_class.call(user: user)

      expect(result.message).to be_present
    end
  end
end
