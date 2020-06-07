require "rails_helper"

describe BroadcastFogArea do
  it "broadcasts the fog area" do
    fog_area = build(:fog_area)
    allow(Maps::FogChannel).to receive(:reveal_area)

    result = described_class.call(fog_area: fog_area)

    expect(result).to be_success
    expect(Maps::FogChannel).to have_received(:reveal_area).with(fog_area)
  end
end
