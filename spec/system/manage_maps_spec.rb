require "rails_helper"

RSpec.describe "manage maps", type: :system do
  it "lists maps" do
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
    attach_file "Image", file_fixture("dwarven-excavation.jpg")
    click_on "Create Map"
    expect(page).to have_content "Dwarven Excavation"
    find(".map-selector__option", text: "Dwarven Excavation").click

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
      attach_file "Image", file_fixture("dwarven-excavation.jpg")
      click_on "Create Map"
      expect(page).to have_content "Dwarven Excavation"
      find(".map-selector__option", text: "Dwarven Excavation").click

      token = campaign.maps.first.tokens.first
      expect(page).to have_token_with_data(token, "token-id", token.id)
    end
  end

  it "validates parameters for map" do
    user = create(:user)
    campaign = create :campaign, user: user
    visit campaign_path(campaign, as: user)
    click_on "New Map"
    fill_in "Name", with: ""
    click_on "Create Map"
    expect(page).to have_content "Name can't be blank"
  end

  it "switches maps" do
    campaign = create :campaign
    create :map, campaign: campaign, name: "Dwarven Excavation"
    create :map, campaign: campaign, name: "Gnomengarde"
    visit campaign_path(campaign, as: campaign.user)
    expect(page).to have_css "h2", text: "No Current Map"
    find(".map-selector__option", text: "Dwarven Excavation").click
    expect(page).to have_css "h2", text: "Dwarven Excavation"
    find(".map-selector__option", text: "Gnomengarde").click
    expect(page).to have_css "h2", text: "Gnomengarde"
  end

  it "moves the map" do
    campaign = create :campaign
    map = create :map, campaign: campaign, name: "Dwarven Excavation", zoom: 0
    visit campaign_path(campaign, as: campaign.user)
    find(".map-selector__option", text: "Dwarven Excavation").click
    click_and_move_map(map, from: { x: 300, y: 300 }, to: { x: 50, y: 50 })

    expect(page).to have_map_with_data(map, "x", "550")
    expect(page).to have_map_with_data(map, "y", "550")
  end

  it "moves the map for other users" do
    campaign = create :campaign
    map = create :map, campaign: campaign, name: "Dwarven Excavation", zoom: 0
    visit campaign_path(campaign, as: campaign.user)
    find(".map-selector__option", text: "Dwarven Excavation").click

    using_session "other user" do
      visit campaign_path(campaign)
    end

    click_and_move_map(map, from: { x: 300, y: 300 }, to: { x: 50, y: 50 })

    using_session "other user" do
      expect(page).to have_map_with_data(map, "x", "550")
      expect(page).to have_map_with_data(map, "y", "550")
    end
  end

  it "zooms the map" do
    campaign = create :campaign
    map = create :map, campaign: campaign, name: "Dwarven Excavation", zoom: 0
    map.center_image

    visit campaign_path(campaign, as: campaign.user)
    find(".map-selector__option", text: "Dwarven Excavation").click

    expect(page).to have_map_with_data(map, "width", "100")
    expect(page).to have_map_with_data(map, "height", "100")
    expect(page).to have_button("-", disabled: true)

    click_on "+"

    expect(page).to have_map_with_data(map, "width", "200")
    expect(page).to have_map_with_data(map, "height", "200")
  end

  it "zooms the map for other users" do
    campaign = create :campaign
    map = create :map, campaign: campaign, name: "Dwarven Excavation", zoom: 0
    map.center_image

    visit campaign_path(campaign, as: campaign.user)
    find(".map-selector__option", text: "Dwarven Excavation").click
    using_session "other user" do
      visit campaign_path(campaign)
    end

    expect(page).to have_map_with_data(map, "width", "100")
    expect(page).to have_map_with_data(map, "height", "100")
    expect(page).to have_button("-", disabled: true)

    click_on "+"

    using_session "other user" do
      expect(page).to have_map_with_data(map, "width", "200")
      expect(page).to have_map_with_data(map, "height", "200")
    end
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

    find(".map-selector__option", text: "Dwarven Excavation").click
    using_session "other user" do
      expect(page).to have_css "h2", text: "Dwarven Excavation"
    end

    find(".map-selector__option", text: "Gnomengarde").click
    using_session "other user" do
      expect(page).to have_css "h2", text: "Gnomengarde"
    end
  end
end
