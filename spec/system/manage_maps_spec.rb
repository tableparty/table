require "rails_helper"

RSpec.describe "manage maps", type: :system do
  it "lists maps" do
    campaign = create :campaign
    create :map, campaign: campaign, name: "Dwarven Excavation"
    visit campaign_path(campaign)
    expect(page).to have_content "Dwarven Excavation"
  end

  it "can create a map" do
    campaign = create :campaign
    visit campaign_path(campaign)
    click_on "New Map"
    fill_in "Name", with: "Dwarven Excavation"
    attach_file "Image", file_fixture("dwarven-excavation.jpg")
    click_on "Create Map"
    expect(page).to have_content "Dwarven Excavation"
  end

  it "validates parameters for map" do
    campaign = create :campaign
    visit campaign_path(campaign)
    click_on "New Map"
    fill_in "Name", with: ""
    click_on "Create Map"
    expect(page).to have_content "Name can't be blank"
  end

  it "switches maps" do
    campaign = create :campaign
    create :map, campaign: campaign, name: "Dwarven Excavation"
    create :map, campaign: campaign, name: "Gnomengarde"
    visit campaign_path(campaign)
    expect(page).to have_css "h2", text: "No Current Map"
    find(".campaign-map-selector", text: "Dwarven Excavation").click
    expect(page).to have_css "h2", text: "Dwarven Excavation"
    find(".campaign-map-selector", text: "Gnomengarde").click
    expect(page).to have_css "h2", text: "Gnomengarde"
  end

  it "switches maps for other users" do
    campaign = create :campaign
    create :map, campaign: campaign, name: "Dwarven Excavation"
    create :map, campaign: campaign, name: "Gnomengarde"
    visit campaign_path(campaign)
    using_session "other user" do
      visit campaign_path(campaign)
      expect(page).to have_css "h2", text: "No Current Map"
    end
    find(".campaign-map-selector", text: "Dwarven Excavation").click
    using_session "other user" do
      expect(page).to have_css "h2", text: "Dwarven Excavation"
    end
    find(".campaign-map-selector", text: "Gnomengarde").click
    using_session "other user" do
      expect(page).to have_css "h2", text: "Gnomengarde"
    end
  end
end
