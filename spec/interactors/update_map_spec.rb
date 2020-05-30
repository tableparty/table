require "rails_helper"

describe UpdateMap do
  it "organizes flow of interactors for editing a map" do
    expect(described_class.organized).to eq(
      [
        SaveMap,
        BroadcastCurrentMap,
        BroadcastMapSelector
      ]
    )
  end
end
