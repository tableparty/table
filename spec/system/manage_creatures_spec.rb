require "rails_helper"

RSpec.describe "manage creatures", type: :system do
  it "can create a creature token" do
    user = create(:user)
    campaign = create(:campaign, user: user)
    map = create(:map, campaign: campaign)
    campaign.update(current_map: map)

    visit campaign_path(campaign, as: user)
    click_on "New Token"
    fill_in "Name", with: "Orc"
    attach_file "Image", file_fixture("uxil.jpeg")
    click_on "Create Creature"

    # if we don't use find here, capybara doesn't wait for the ajax to complete
    html_token = find(".token[data-target='map.token']")
    token = campaign.current_map.tokens.last
    expect(html_token["data-token-id"]).to eq token.id
    expect(token.name).to eq "Orc"
  end

  it "copies creature tokens from the drawer to the map" do
    map = create :map
    creature = create :creature, campaign: map.campaign
    token = create :token, map: map, stashed: true, tokenable: creature

    visit campaign_path(map.campaign, as: map.campaign.user)
    wait_for_connection
    find(".map-selector__option", text: map.name).click
    token_element = token_element(token)
    token_element.drag_to(map_element(map), html5: true)

    expect(map_element(map)).not_to have_token(token)
    expect(map_element(map)).to have_token_with_identifier(
      creature.tokens.order(created_at: :asc).last,
      "1"
    )
    expect(token_drawer_element).to have_token(token)
  end

  def token_drawer_element
    find(".current-map__token-drawer")
  end
end
