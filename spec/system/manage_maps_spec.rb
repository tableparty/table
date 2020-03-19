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
end
