require "rails_helper"

RSpec.describe "manage campaigns", type: :system do
  it "lists campaigns" do
    Campaign.create(name: "Dragon of Icespire Peak")
    visit campaigns_path
    expect(page).to have_content "Dragon of Icespire Peak"
  end

  it "can create a campaign" do
    visit campaigns_path
    click_on "New Campaign"
    fill_in "Name", with: "Dragon of Icespire Peak"
    click_on "Create Campaign"
    expect(page).to have_content "Dragon of Icespire Peak"
  end

  it "validates parameters for campaign" do
    visit campaigns_path
    click_on "New Campaign"
    fill_in "Name", with: ""
    click_on "Create Campaign"
    expect(page).to have_content "Name can't be blank"
  end
end
