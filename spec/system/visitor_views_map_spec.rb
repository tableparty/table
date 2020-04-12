require "rails_helper"

RSpec.describe "Visitor viewing a map", type: :system do
  it "cannot zoom the map" do
    map = create :map, name: "Dwarven Excavation"
    map.campaign.update(current_map: map)

    visit campaign_path(map.campaign)

    expect(page).not_to have_button("-")
    expect(page).not_to have_button("+")
  end

  it "cannot move the map" do
    map = create :map, name: "Dwarven Excavation"
    map.campaign.update(current_map: map)

    visit campaign_path(map.campaign)
    click_and_move_map(map, from: { x: 300, y: 300 }, to: { x: 50, y: 50 })

    expect(page).to have_map_with_data(map, "x", "50")
    expect(page).to have_map_with_data(map, "y", "50")
  end

  it "does not see option to create new maps" do
    campaign = create :campaign
    create :map, campaign: campaign, name: "Dwarven Excavation"
    visit campaign_path(campaign)
    expect(page).not_to have_content "New Map"
  end

  it "does not see option to create new characters" do
    campaign = create(:campaign)

    visit campaign_path(campaign)

    expect(page).not_to have_content "New Character"
  end
end
