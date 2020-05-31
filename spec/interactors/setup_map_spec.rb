require "rails_helper"

describe SetupMap do
  it "centers the map" do
    map = instance_double(Map, center_image: true, populate_characters: nil)

    result = described_class.call(map: map)

    expect(result).to be_success
    expect(map).to have_received(:center_image)
  end

  it "populates the map" do
    map = instance_double(Map, center_image: true, populate_characters: nil)

    result = described_class.call(map: map)

    expect(result).to be_success
    expect(map).to have_received(:populate_characters)
  end
end
