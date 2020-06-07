require "rails_helper"

describe CreateNewFogArea do
  it "organizes flow of intereactors to create and setup a fog area" do
    expect(described_class.organized).to eq(
      [
        CreateFogArea,
        BroadcastFogArea
      ]
    )
  end
end
