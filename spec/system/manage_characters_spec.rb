require "rails_helper"

RSpec.describe "manage characters", type: :system do
  it "can create a character" do
    user = create(:user)
    campaign = create(:campaign, user: user)
    map = create(:map, campaign: campaign)
    campaign.update(current_map: map)

    visit campaign_path(campaign, as: user)
    click_on "New Token"
    find("label", text: "Character").click
    fill_in "Name", with: "Uxil"
    attach_file "Image", file_fixture("uxil.jpeg")
    click_on "Create Character"

    # if we don't use find here, capybara doesn't wait for the ajax to complete
    html_token = find(".token[data-target='map.token']")
    character = campaign.characters.last
    expect(character.name).to eq "Uxil"
    expect(html_token["data-token-id"]).to eq character.tokens.first.id
  end

  it "sees errors when creating invalid character" do
    user = create(:user)
    campaign = create(:campaign, user: user)
    map = create(:map, campaign: campaign)
    campaign.update(current_map: map)

    visit campaign_path(campaign, as: user)
    click_on "New Token"
    find("label", text: "Character").click
    click_on "Create Character"

    expect(page).to have_content "Name can't be blank"
    expect(page).to have_content "Image can't be blank"
  end

  it "moves character tokens from the drawer to the map" do
    map = create :map
    character = create :character, campaign: map.campaign
    token = create :token, map: map, stashed: true, token_template: character
    visit campaign_path(map.campaign, as: map.campaign.user)
    wait_for_connection
    find(".map-selector__option", text: map.name).click
    token_element = token_element(token)
    token_element.drag_to(map_element(map), html5: true)
    expect(map_element(map)).to have_token(token)
    expect(token_drawer_element).not_to have_token(token)
  end

  def token_drawer_element
    find(".current-map__token-drawer")
  end
end
