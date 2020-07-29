require "rails_helper"

RSpec.describe "map fog", type: :system do
  context "when creating a map with the fog feature active" do
    it "allows enabling fog" do
      user = create(:user, email: "jdbann@icloud.com")
      campaign = create(:campaign, user: user)
      visit campaign_path(campaign, as: user)
      click_on "New Map"
      fill_in "Name", with: "Dwarven Excavation"
      attach_file "Image", file_fixture("map.jpg")
      fill_in "Grid size", with: "43"
      check "Enable fog"
      click_on "Create Map"
      expect(page).to have_css("[data-target='map--fog.canvas']")
    end
  end

  context "when creating a map without the fog feature active" do
    it "doesn't allow enabling fog" do
      user = create(:user)
      campaign = create(:campaign, user: user)
      visit campaign_path(campaign, as: user)
      click_on "New Map"
      expect(page).not_to have_content "Enable fog"
    end
  end

  it "renders existing fog areas" do
    map = create :map, :current, fog_enabled: true
    create :fog_area, map: map

    visit campaign_path(map.campaign, as: map.campaign.user)
    wait_for_connection

    fog_controller = find("[data-target~='map--fog.canvas']", visible: false)
    fog_areas = JSON.parse(fog_controller["data-map--fog-areas"])
    expect(fog_areas.count).to eq 1
  end

  it "adds a new path to the fog mask" do
    map = create :map, :current, fog_enabled: true

    visit campaign_path(map.campaign, as: map.campaign.user)
    wait_for_connection
    map_node = map_element(map)
    shift_click_at(map_node, relative_position_of(map_node, x: 0.1, y: 0.1))
    mouse_move_to(relative_position_of(map_node, x: 0.9, y: 0.1))
    mouse_move_to(relative_position_of(map_node, x: 0.9, y: 0.9))
    mouse_move_to(relative_position_of(map_node, x: 0.1, y: 0.9))
    mouse_release
    fog_controller = find("[data-target~='map--fog.canvas']", visible: false)
    fog_areas = JSON.parse(fog_controller["data-map--fog-areas"])

    expect(fog_areas.count).to eq 1
  end

  it "adds a new path to the fog mask for other users" do
    map = create :map, :current, fog_enabled: true

    visit campaign_path(map.campaign, as: map.campaign.user)
    wait_for_connection

    using_session "other user" do
      visit campaign_path(map.campaign)
      wait_for_connection
    end

    map_node = map_element(map)
    shift_click_at(map_node, relative_position_of(map_node, x: 0.1, y: 0.1))
    mouse_move_to(relative_position_of(map_node, x: 0.9, y: 0.1))
    mouse_move_to(relative_position_of(map_node, x: 0.9, y: 0.9))
    mouse_move_to(relative_position_of(map_node, x: 0.1, y: 0.9))
    mouse_release

    using_session "other user" do
      # Wait for the cable
      find("[data-target~='map--fog.canvas'][data-map--fog-areas*='id']")

      fog_controller = find("[data-target~='map--fog.canvas']", visible: false)
      fog_areas = JSON.parse(fog_controller["data-map--fog-areas"])
      expect(fog_areas.count).to eq 1
    end
  end

  context "with fog disabled" do
    it "doesn't add a new path to the fog mask" do
      map = create :map, :current

      visit campaign_path(map.campaign, as: map.campaign.user)
      wait_for_connection

      expect(page).not_to have_css(
        "[data-target='map--fog.canvas']", visible: false
      )
    end
  end
end
