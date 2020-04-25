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
      click_on "Create"
    end

    # if we don't use find here, capybara doesn't wait for the ajax to complete
    html_token = find(".token[data-target='map.token']")
    token = map.reload.tokens.first
    expect(html_token["data-token-id"]).to eq token.id
  end
end
