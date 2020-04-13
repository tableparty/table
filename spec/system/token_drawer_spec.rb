require "rails_helper"

RSpec.describe "token drawer", type: :system do
  it "moves tokens from the drawer to the map" do
    map = create :map
    token = create :token, map: map, stashed: true
    visit campaign_path(map.campaign, as: map.campaign.user)
    wait_for_connection
    find(".map-selector__option", text: map.name).click
    token_element = token_element(token)
    token_element.drag_to(map_element(map), html5: true)
    expect(map_element(map)).to have_token(token)
  end

  it "adds the token to the map for other users" do
    map = create :map
    token = create :token, map: map, stashed: true

    visit campaign_path(map.campaign, as: map.campaign.user)
    find(".map-selector__option", text: map.name).click
    wait_for_connection
    using_session "other user" do
      visit campaign_path(map.campaign)
      wait_for_connection
    end

    token_element = token_element(token)
    token_element.drag_to(map_element(map), html5: true)

    using_session "other user" do
      expect(page).to have_token(token)
    end
  end

  it "moves tokens from the map to the drawer" do
    map = create :map
    token = create :token, map: map, stashed: false
    visit campaign_path(map.campaign, as: map.campaign.user)
    wait_for_connection
    find(".map-selector__option", text: map.name).click
    token_element = token_element(token)
    token_element.drag_to(token_drawer_element, html5: true)
    expect(token_drawer_element).to have_token(token)
    expect(map_element(map)).not_to have_token(token)
  end

  it "hides the token for other users" do
    map = create :map
    token = create :token, map: map, stashed: false

    visit campaign_path(map.campaign, as: map.campaign.user)
    wait_for_connection
    find(".map-selector__option", text: map.name).click
    using_session "other user" do
      visit campaign_path(map.campaign)
      wait_for_connection
    end

    token_element = token_element(token)
    token_element.drag_to(token_drawer_element, html5: true)

    using_session "other user" do
      expect(page).not_to have_token(token)
    end
  end

  def token_drawer_element
    find(".current-map__token-drawer")
  end
end
