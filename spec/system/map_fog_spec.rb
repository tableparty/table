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
      expect(page).to have_content "Dwarven Excavation"
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
    map = create :map, fog_enabled: true
    create :fog_area, map: map
    visit campaign_path(map.campaign, as: map.campaign.user)
    wait_for_connection
    find(".map-selector__option", text: map.name).click
    mask_node = find("[data-target='map--fog.fogMask']", visible: false)
    path_node = mask_node.find("path", visible: false)
    path_with_four_points = /M (?:-?\d+ ){2}(?:L (?:-?\d+ ){2}){3}Z/
    expect(path_node["d"]).to match(path_with_four_points)
  end

  it "adds a new path to the fog mask" do
    map = create :map, fog_enabled: true
    visit campaign_path(map.campaign, as: map.campaign.user)
    wait_for_connection
    find(".map-selector__option", text: map.name).click
    map_node = map_element(map)
    shift_click_at(map_node, relative_position_of(map_node, x: 0.1, y: 0.1))
    mouse_move_to(relative_position_of(map_node, x: 0.9, y: 0.1))
    mouse_move_to(relative_position_of(map_node, x: 0.9, y: 0.9))
    mouse_move_to(relative_position_of(map_node, x: 0.1, y: 0.9))
    mouse_release
    mask_node = find("[data-target='map--fog.fogMask']", visible: false)
    path_node = mask_node.find("path", visible: false)
    path_with_four_points = /M (?:-?\d+ ){2}(?:L (?:-?\d+ ){2}){3}Z/
    expect(path_node["d"]).to match(path_with_four_points)
  end

  it "adds a new path to the fog mask for other users" do
    map = create :map, fog_enabled: true
    visit campaign_path(map.campaign, as: map.campaign.user)
    wait_for_connection
    find(".map-selector__option", text: map.name).click

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
      mask_node = find("[data-target='map--fog.fogMask']", visible: false)
      path_node = mask_node.find("path", visible: false)
      path_with_four_points = /M (?:-?\d+ ){2}(?:L (?:-?\d+ ){2}){3}Z/
      expect(path_node["d"]).to match(path_with_four_points)
    end
  end

  context "with fog disabled" do
    it "doesn't add a new path to the fog mask" do
      map = create :map
      visit campaign_path(map.campaign, as: map.campaign.user)
      wait_for_connection
      find(".map-selector__option", text: map.name).click
      expect(page).not_to have_css(
        "[data-target='map--fog.fogMask']", visible: false
      )
    end
  end
end
