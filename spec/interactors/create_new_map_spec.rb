require "rails_helper"

describe CreateNewMap do
  it "organizes flow of interactors to create and setup a map" do
    expect(described_class.organized).to eq(
      [
        CreateMap,
        SetupMap,
        ChangeCurrentMap,
        BroadcastCurrentMap,
        BroadcastMapSelector
      ]
    )
  end
end
