require "rails_helper"

RSpec.describe "move tokens", type: :system do
  it "shows tokens on the map" do
    map = create :map
    token = create :token, map: map
    visit campaign_path(map.campaign)
    find(".campaign-map-selector", text: map.name).click
    expect(page).to have_token_with_data(token, "token-id", token.id)
  end

  it "drags tokens" do
    map = create :map, zoom: 2
    token = create :token, map: map, x: 0, y: 0
    visit campaign_path(map.campaign)
    find(".campaign-map-selector", text: map.name).click

    click_and_move_token(token, by: { x: 50, y: 50 })

    expect(page).to have_token_with_data(token, "x", 50)
    expect(page).to have_token_with_data(token, "y", 50)
  end

  it "factors in map zoom when dragging" do
    map = create :map, zoom: 0
    token = create :token, map: map, x: 0, y: 0
    visit campaign_path(map.campaign)
    find(".campaign-map-selector", text: map.name).click

    click_and_move_token(token, by: { x: 50, y: 50 })

    expect(page).to have_token_with_data(token, "x", 200)
    expect(page).to have_token_with_data(token, "y", 200)
  end

  it "moves the token for other users" do
    map = create :map, zoom: 2
    token = create :token, map: map, x: 0, y: 0
    visit campaign_path(map.campaign)
    find(".campaign-map-selector", text: map.name).click

    using_session "other user" do
      visit campaign_path(map.campaign)
    end

    click_and_move_token(token, by: { x: 50, y: 50 })

    using_session "other user" do
      expect(page).to have_token_with_data(token, "x", 50)
      expect(page).to have_token_with_data(token, "y", 50)
    end
  end

  def have_token_with_data(token, attribute, value)
    have_css(
      ".token[data-token-id='#{token.id}'][data-#{attribute}='#{value}']"
    )
  end
end
