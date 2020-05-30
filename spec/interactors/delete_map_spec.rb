require "rails_helper"

describe DeleteMap do
  it "organizes flow of interactors to destroy a map" do
    expect(described_class.organized).to eq(
      [
        PrepareMapForDeletion,
        DestroyMap,
        BroadcastMapSelector
      ]
    )
  end
end
