require "rails_helper"

RSpec.describe "manage characters", type: :system do
  it "can create a character" do
    user = create(:user)
    campaign = create(:campaign, user: user)
    map = create(:map, campaign: campaign)
    campaign.update(current_map: map)

    visit campaign_path(campaign, as: user)
    open_token_drawer
    within token_drawer do
      click_on "New Token"
    end
    within modal do
      find("label", text: "Character").click
      fill_in "Name", with: "Uxil"
      attach_file "Image", file_fixture("thief.jpg")
      click_on "Create Character"
    end

    # if we don't use find here, capybara doesn't wait for the ajax to complete
    html_token = find(".token[data-target='map--tokens.token']")
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
    open_token_drawer
    within token_drawer do
      click_on "New Token"
    end
    within modal do
      find("label", text: "Character").click
      click_on "Create Character"
    end

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
    open_token_drawer
    token_element = token_element(token)
    token_element.drag_to(map_element(map), html5: true)

    expect(map_element(map)).to have_token(token)
    expect(token_drawer).not_to have_token(token)
  end
end
