require "rails_helper"

RSpec.describe "manage campaigns", type: :system do
  it "lists campaigns" do
    user = create(:user)
    Campaign.create(name: "Dragon of Icespire Peak", user: user)
    visit campaigns_path(as: user)
    expect(page).to have_content "Dragon of Icespire Peak"
  end

  it "does not show campaigns for other users" do
    user = create(:user)
    other_user = create(:user)
    Campaign.create(name: "Dragon of Icespire Peak", user: other_user)
    visit campaigns_path(as: user)
    expect(page).not_to have_content "Dragon of Icespire Peak"
  end

  it "can create a campaign" do
    user = create(:user)
    visit campaigns_path(as: user)
    click_on "New Campaign"
    fill_in "Name", with: "Dragon of Icespire Peak"
    click_on "Create Campaign"
    expect(page).to have_content "Dragon of Icespire Peak"
  end

  it "validates parameters for campaign" do
    user = create(:user)
    visit campaigns_path(as: user)
    click_on "New Campaign"
    fill_in "Name", with: ""
    click_on "Create Campaign"
    expect(page).to have_content "Name can't be blank"
  end
end
