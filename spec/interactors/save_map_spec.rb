require "rails_helper"

describe SaveMap do
  it "updates the map with the given attributes hash" do
    map = instance_double(Map, update: true)
    map_params = {}

    result = described_class.call(map: map, map_params: map_params)

    expect(result).to be_success
    expect(map).to have_received(:update).with(map_params)
    expect(result.map).to eq map
  end

  describe "when saving fails" do
    it "fails the interaction" do
      map = instance_double(Map, update: false)
      map_params = {}

      result = described_class.call(map: map, map_params: map_params)

      expect(result).not_to be_success
      expect(result.map).to eq map
    end
  end
end
