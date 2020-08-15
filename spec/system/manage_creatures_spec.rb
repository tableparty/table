require "rails_helper"

RSpec.describe "manage creatures", type: :system do
  it "can create a creature token" do
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
      fill_in "Name", with: "Orc"
      attach_file "Image", file_fixture("thief.jpg")
      click_on "Create Creature"
    end

    # if we don't use find here, capybara doesn't wait for the ajax to complete
    html_token = find(".token[data-target='map--tokens.token']")
    token = campaign.current_map.tokens.last
    expect(html_token["data-token-id"]).to eq token.id
    expect(token.name).to eq "Orc"
  end

  it "can create a large creature token" do
    base_token_size = 40
    base_drawer_size = (base_token_size * 1.25).round
    large_map_size = (base_token_size * Token::SIZES["large"]).round
    user = create(:user)
    campaign = create(:campaign, user: user)
    map = create(:map, campaign: campaign, zoom: 2)
    campaign.update(current_map: map)

    visit campaign_path(campaign, as: user)
    open_token_drawer
    within token_drawer do
      click_on "New Token"
    end
    within modal do
      fill_in "Name", with: "Ogre"
      select "Large"
      attach_file "Image", file_fixture("thief.jpg")
      click_on "Create Creature"
    end

    drawer_token = find(
      ".current-map__token-drawer .token[data-target='map--tokens.token']"
    )
    expect(drawer_token.native.size.width).to eq base_drawer_size
    expect(drawer_token.native.size.height).to eq base_drawer_size

    drawer_token.drag_to(map_element(map), html5: true)

    map_token = find(".current-map .token[data-target='map--tokens.token']")
    expect(map_token.native.size.width).to eq large_map_size
    expect(map_token.native.size.height).to eq large_map_size
  end

  it "copies creature tokens from the drawer to the map" do
    map = create :map
    creature = create :creature, campaign: map.campaign
    token = create :token, map: map, stashed: true, token_template: creature

    visit campaign_path(map.campaign, as: map.campaign.user)
    wait_for_connection
    find(".map-selector__option", text: map.name).click
    open_token_drawer
    token_element = token_element(token)
    token_element.drag_to(map_element(map), html5: true)

    expect(map_element(map)).not_to have_token(token)
    expect(map_element(map)).to have_token_with_identifier(
      creature.tokens.order(created_at: :asc).last,
      "1"
    )
    open_token_drawer
    expect(token_drawer).to have_token(token)
  end
end
