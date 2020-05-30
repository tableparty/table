require "rails_helper"

describe DestroyMap do
  it "destroys the map" do
    campaign = instance_double(Campaign, current_map: nil)
    map = instance_double(Map, destroy: true)

    result = described_class.call(campaign: campaign, map: map)

    expect(result).to be_success
    expect(map).to have_received(:destroy)
  end

  describe "when destroying fails" do
    it "fails the interaction" do
      campaign = instance_double(Campaign, current_map: nil)
      map = instance_double(Map, destroy: false)

      result = described_class.call(campaign: campaign, map: map)

      expect(result).not_to be_success
    end
  end
end
