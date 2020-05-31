require "rails_helper"

describe BroadcastCurrentMap do
  it "broadcasts the current map" do
    map = instance_double(Map)
    campaign = instance_double(Campaign, current_map: map)
    allow(CampaignChannel).to receive(:broadcast_current_map)

    result = described_class.call(campaign: campaign, map: map)

    expect(result).to be_success
    expect(CampaignChannel)
      .to have_received(:broadcast_current_map).with(campaign)
  end
end
