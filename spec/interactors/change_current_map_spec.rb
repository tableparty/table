require "rails_helper"

describe ChangeCurrentMap do
  it "organizes flow of interactors to create and setup a map" do
    expect(described_class.organized).to eq(
      [
        SetCurrentMap,
        BroadcastCurrentMap
      ]
    )
  end
end
