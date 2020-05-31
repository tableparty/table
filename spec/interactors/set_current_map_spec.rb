require "rails_helper"

describe SetCurrentMap do
  it "sets the campaign's current map to the context map" do
    map = instance_double(Map)
    campaign = instance_double(Campaign, update: true)

    result = described_class.call(campaign: campaign, map: map)

    expect(result).to be_success
    expect(campaign).to have_received(:update).with(current_map: map)
  end

  it "fails the interaction if saving the current map fails" do
    map = instance_double(Map)
    campaign = instance_double(Campaign, update: false)

    result = described_class.call(campaign: campaign, map: map)

    expect(result).not_to be_success
    expect(campaign).to have_received(:update).with(current_map: map)
  end
end
