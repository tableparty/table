require "rails_helper"

RSpec.describe Map, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:campaign) }
    it { is_expected.to have_one(:image_attachment) }
    it { is_expected.to have_one(:image_blob) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :image }
    it { is_expected.to validate_inclusion_of(:zoom).in_range(0..4) }
  end

  describe "#zoom_amount" do
    it "returns the amount of zoom at the current zoom level" do
      map = described_class.new(zoom: 1)

      expect(map.zoom_amount).to eq Map::ZOOM_LEVELS[map.zoom]
    end
  end

  describe "#original_height" do
    it "returns the height of the attached image" do
      map = create(:map)
      map.image.analyze

      expect(map.original_height).to eq map.image.metadata[:height]
    end
  end

  describe "#original_width" do
    it "returns the width of the attached image" do
      map = create(:map)
      map.image.analyze

      expect(map.original_width).to eq map.image.metadata[:width]
    end
  end

  describe "#height" do
    it "returns the integer zoomed height" do
      map = create(:map, zoom: 0)
      map.image.analyze

      expect(map.height).to eq(
        (map.image.metadata[:height] * map.zoom_amount).round
      )
    end
  end

  describe "#width" do
    it "returns the integer zoomed width" do
      map = create(:map, zoom: 0)
      map.image.analyze

      expect(map.width).to eq(
        (map.image.metadata[:width] * map.zoom_amount).round
      )
    end
  end

  describe "#center_image" do
    it "sets x and y to the center of the image at the current zoom_level" do
      map = create(:map, zoom: 0)

      map.center_image

      expect(map.x).to eq(
        ((map.original_width * map.zoom_amount) / 2).round
      )
      expect(map.y).to eq(
        ((map.original_height * map.zoom_amount) / 2).round
      )
    end
  end

  describe "updating the zoom level" do
    it "transforms the current x coordinate to match the new size" do
      original_x = 50
      zoom_change = (Map::ZOOM_LEVELS[1] / Map::ZOOM_LEVELS[0])
      map = create(:map, zoom: 0, x: original_x)

      map.update(zoom: 1)

      expect(map.x).to eq original_x * zoom_change
    end

    it "transforms the current y coordinate to match the new size" do
      original_y = 50
      zoom_change = (Map::ZOOM_LEVELS[1] / Map::ZOOM_LEVELS[0])
      map = create(:map, zoom: 0, y: original_y)

      map.update(zoom: 1)

      expect(map.y).to eq original_y * zoom_change
    end
  end
end
