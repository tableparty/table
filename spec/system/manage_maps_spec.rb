require "rails_helper"

RSpec.describe "manage maps", type: :system do
  it "lists maps when no map selected" do
    campaign = create :campaign
    create :map, campaign: campaign, name: "Dwarven Excavation"

    visit campaign_path(campaign, as: campaign.user)

    expect(page).to have_content "Dwarven Excavation"
  end

  it "can create a map" do
    user = create(:user)
    campaign = create(:campaign, user: user)
    visit campaign_path(campaign, as: user)
    click_on "New Map"
    fill_in "Name", with: "Dwarven Excavation"
    attach_file "Image", file_fixture("map.jpg")
    fill_in "Grid size", with: "43"
    click_on "Create Map"
    expect(page).to have_content "Dwarven Excavation"
    open_selector_and_switch_to_map("Dwarven Excavation")

    map = campaign.maps.first
    expect(page).to have_map_with_data(map, "x", (map.width / 2).to_s)
    expect(page).to have_map_with_data(map, "y", (map.height / 2).to_s)
  end

  context "when creating a map for a campaign with characters" do
    it "auto-populates the character tokens on the map" do
      user = create(:user)
      campaign = create(:campaign, user: user)
      create(:character, campaign: campaign)

      visit campaign_path(campaign, as: user)
      click_on "New Map"
      fill_in "Name", with: "Dwarven Excavation"
      attach_file "Image", file_fixture("map.jpg")
      fill_in "Grid size", with: "43"
      click_on "Create Map"
      expect(page).to have_content "Dwarven Excavation"
      open_selector_and_switch_to_map("Dwarven Excavation")

      token = campaign.maps.first.tokens.first
      expect(page).to have_token_with_data(token, "token-id", token.id)
    end
  end

  it "validates parameters for new map" do
    user = create(:user)
    campaign = create :campaign, user: user

    visit campaign_path(campaign, as: user)
    click_on "New Map"
    fill_in "Name", with: ""
    click_on "Create Map"

    expect(page).to have_content "Name can't be blank"
  end

  it "can edit a map" do
    user = create(:user)
    campaign = create(:campaign, user: user)
    map = create(:map, campaign: campaign)

    visit campaign_path(campaign, as: user)
    hover_over_map_selector_for(map)
    click_on "Edit"
    fill_in "Name", with: "Edited Map Name"
    click_on "Update Map"

    expect(page).to have_content "Edited Map Name"
    expect(map.reload.name).to eq "Edited Map Name"
  end

  it "can edit a map for other users" do
    user = create(:user)
    campaign = create(:campaign, user: user)
    map = create(:map, :current, campaign: campaign)

    using_session "other user" do
      visit campaign_path(campaign)
    end

    visit campaign_path(campaign, as: user)
    open_map_selector
    hover_over_map_selector_for(map)
    click_on "Edit"
    fill_in "Name", with: "Edited Map Name"
    click_on "Update Map"

    using_session "other user" do
      expect(page).to have_content "Edited Map Name"
    end

    expect(page).to have_content "Edited Map Name"
    expect(map.reload.name).to eq "Edited Map Name"
  end

  it "validates parameters when editing maps" do
    user = create(:user)
    campaign = create(:campaign, user: user)
    map = create(:map, campaign: campaign)

    visit campaign_path(campaign, as: user)
    hover_over_map_selector_for(map)
    click_on "Edit"
    fill_in "Name", with: ""
    click_on "Update Map"

    expect(page).to have_content "Name can't be blank"
  end

  it "can delete the current map" do
    user = create(:user)
    campaign = create(:campaign, user: user)
    map = create(:map, :current, campaign: campaign)

    visit campaign_path(campaign, as: user)
    open_map_selector
    hover_over_map_selector_for(map)
    click_on "Edit"
    accept_confirm do
      click_on "Delete"
    end

    expect(page).not_to have_content map.name
    expect(page).to have_content "No Current Map"
  end

  it "deletes the map for other users" do
    user = create(:user)
    campaign = create(:campaign, user: user)
    map = create(:map, :current, campaign: campaign)

    using_session "other user" do
      visit campaign_path(campaign)
    end

    visit campaign_path(campaign, as: user)
    open_map_selector
    hover_over_map_selector_for(map)
    click_on "Edit"
    accept_confirm do
      click_on "Delete"
    end

    using_session "other user" do
      expect(page).not_to have_content map.name
      expect(page).to have_content "No Current Map"
    end

    expect(page).not_to have_content map.name
    expect(page).to have_content "No Current Map"
  end

  it "switches maps" do
    campaign = create :campaign
    create :map, campaign: campaign, name: "Dwarven Excavation"
    create :map, campaign: campaign, name: "Gnomengarde"

    visit campaign_path(campaign, as: campaign.user)
    expect(page).to have_css "h2", text: "No Current Map"
    switch_to_map("Dwarven Excavation")
    expect(page).to have_css "h2", text: "Dwarven Excavation"
    open_selector_and_switch_to_map("Gnomengarde")
    expect(page).to have_css "h2", text: "Gnomengarde"
  end

  it "moves the map" do
    campaign = create :campaign
    map = create :map, :current, campaign: campaign, zoom: 0

    visit campaign_path(campaign, as: campaign.user)
    click_and_move_map(map, from: { x: 300, y: 300 }, to: { x: 50, y: 50 })

    expect(page).to have_map_with_data(map, "x", "550")
    expect(page).to have_map_with_data(map, "y", "550")
  end

  it "zooms the map" do
    campaign = create :campaign
    map = create :map, :current, campaign: campaign, zoom: 0
    map.center_image

    visit campaign_path(campaign, as: campaign.user)

    expect(page).to have_map_with_data(map, "zoom", "0")
    expect(find("[data-target='map.zoomOut']")).to be_disabled

    find(".current-map__zoom-in").click

    expect(page).to have_map_with_data(map, "zoom", "1")
  end

  it "switches maps for other users" do
    campaign = create :campaign
    create :map, campaign: campaign, name: "Dwarven Excavation"
    create :map, campaign: campaign, name: "Gnomengarde"

    visit campaign_path(campaign, as: campaign.user)
    using_session "other user" do
      visit campaign_path(campaign)
      expect(page).to have_css "h2", text: "No Current Map"
    end

    switch_to_map("Dwarven Excavation")
    using_session "other user" do
      expect(page).to have_css "h2", text: "Dwarven Excavation"
      expect(page).not_to have_css("[data-target='map.tokenDrawer']")
    end

    open_selector_and_switch_to_map("Gnomengarde")
    using_session "other user" do
      expect(page).to have_css "h2", text: "Gnomengarde"
      expect(page).not_to have_css("[data-target='map.tokenDrawer']")
    end
  end

  def hover_over_map_selector_for(map)
    within "[data-target*='campaign.mapSelector']" do
      find("[data-map-id='#{map.id}']").hover
    end
  end
end
