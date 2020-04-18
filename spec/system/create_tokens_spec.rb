require "rails_helper"

RSpec.describe "create tokens", type: :system do
  it "creates a with name and image, showing it on the map" do
    user = create(:user)
    campaign = create(:campaign, user: user)
    map = create(:map, campaign: campaign)
    map.campaign.update(current_map: map)
    expect(map.tokens).to be_empty

    visit campaign_path(map.campaign, as: user)
    wait_for_connection
    click_on "New Token"
    within "[data-controller=modal]" do
      fill_in "Name", with: "Olokas"
      attach_file "Image", file_fixture("olokas.jpeg")
      click_on "Create Token"
    end

    token = map.reload.tokens.first
    expect(page).to have_token(token)
  end

  it "shows the new token to other users" do
    user = create(:user)
    campaign = create(:campaign, user: user)
    map = create(:map, campaign: campaign)
    map.campaign.update(current_map: map)

    visit campaign_path(map.campaign, as: user)
    wait_for_connection
    using_session "other user" do
      visit campaign_path(map.campaign)
      wait_for_connection
    end
    click_on "New Token"
    fill_in "Name", with: "Olokas"
    attach_file "Image", file_fixture("olokas.jpeg")
    click_on "Create Token"

    token = map.reload.tokens.first
    using_session "other user" do
      expect(page).to have_token(token)
    end
  end
end
