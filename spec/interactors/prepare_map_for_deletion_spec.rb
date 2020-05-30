require "rails_helper"

describe PrepareMapForDeletion do
  describe "when the given map is the current map" do
    it "unsets the current map" do
      map = instance_double(Map)
      campaign = instance_double(Campaign, current_map: map)
      result = instance_double(Interactor::Context, success?: true)
      allow(ChangeCurrentMap).to receive(:call).and_return(result)

      result = described_class.call(campaign: campaign, map: map)

      expect(result).to be_success
      expect(ChangeCurrentMap)
        .to have_received(:call).with(campaign: campaign, map: nil)
    end
  end

  describe "when the given map is not the current map" do
    it "does not change the current map" do
      map = instance_double(Map)
      campaign = instance_double(Campaign, current_map: nil)
      allow(ChangeCurrentMap).to receive(:call)

      result = described_class.call(campaign: campaign, map: map)

      expect(result).to be_success
      expect(ChangeCurrentMap).not_to have_received(:call)
    end
  end

  describe "when unsetting the current map fails" do
    it "fails the interaction the current map" do
      map = instance_double(Map)
      campaign = instance_double(Campaign, current_map: map)
      result = instance_double(Interactor::Context, success?: false)
      allow(ChangeCurrentMap).to receive(:call).and_return(result)

      result = described_class.call(campaign: campaign, map: map)

      expect(result).not_to be_success
      expect(ChangeCurrentMap)
        .to have_received(:call).with(campaign: campaign, map: nil)
    end
  end
end
