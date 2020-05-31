require "rails_helper"

describe CreateMap do
  it "adds the created map to the context" do
    campaign, maps_relation, map = double_map_and_campaign(success: true)
    map_params = {}

    result = described_class.call(campaign: campaign, map_params: map_params)

    expect(result).to be_success
    expect(maps_relation).to have_received(:create).with(map_params)
    expect(result.map).to eq map
  end

  describe "when creation fails" do
    it "fails the interaction and adds the map to the context" do
      campaign, maps_relation, map = double_map_and_campaign(success: false)
      map_params = {}

      result = described_class.call(campaign: campaign, map_params: map_params)

      expect(result).not_to be_success
      expect(maps_relation).to have_received(:create).with(map_params)
      expect(result.map).to eq map
    end
  end

  def double_map_and_campaign(success:)
    map = instance_double(Map, persisted?: success)
    maps_relation = instance_double(
      ActiveRecord::Associations::CollectionProxy,
      create: map
    )
    campaign = instance_double(Campaign, maps: maps_relation)
    [campaign, maps_relation, map]
  end
end
