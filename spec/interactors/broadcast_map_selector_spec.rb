require "rails_helper"

describe BroadcastMapSelector do
  it "broadcasts the map selector" do
    map = instance_double(Map)
    campaign = instance_double(Campaign)
    allow(CampaignChannel).to receive(:broadcast_map_selector)

    result = described_class.call(campaign: campaign, map: map)

    expect(result).to be_success
    expect(CampaignChannel)
      .to have_received(:broadcast_map_selector).with(campaign)
  end
end
