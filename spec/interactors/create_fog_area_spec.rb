require "rails_helper"

describe CreateFogArea do
  context "with valid params" do
    it "creates a new fog area" do
      map = create(:map)
      fog_area_params = attributes_for(:fog_area)

      expect do
        described_class.call(map: map, fog_area_params: fog_area_params)
      end.to change(map.fog_areas, :count).by(1)
    end

    it "adds the fog area to the context" do
      map = create(:map)
      fog_area_params = attributes_for(:fog_area)

      result = described_class.call(map: map, fog_area_params: fog_area_params)

      expect(result.fog_area.id).to eq fog_area_params[:id]
    end

    it "returns successful" do
      map = create(:map)
      fog_area_params = attributes_for(:fog_area)

      result = described_class.call(map: map, fog_area_params: fog_area_params)

      expect(result).to be_success
    end
  end

  context "with invalid params" do
    it "returns unsuccessful" do
      map = create(:map)
      fog_area_params = {}

      result = described_class.call(map: map, fog_area_params: fog_area_params)

      expect(result).to be_failure
    end
  end
end
