require "rails_helper"

RSpec.describe "move tokens", type: :system do
  it "shows tokens on the map" do
    map = create :map, :current
    token = create :token, map: map, stashed: false

    visit campaign_path(map.campaign, as: map.campaign.user)
    wait_for_connection

    expect(page).to have_token_with_data(token, "token-id", token.id)
  end

  it "drags tokens" do
    map = create :map, :current, zoom: 2
    token = create :token, map: map, x: 0, y: 0, stashed: false

    visit campaign_path(map.campaign)
    wait_for_connection
    click_and_move_token(token, by: { x: 50, y: 50 })

    expect(page).to have_token_with_data(token, "x", 50)
    expect(page).to have_token_with_data(token, "y", 50)
  end

  it "factors in map zoom when dragging" do
    map = create :map, :current, zoom: 0
    token = create :token, map: map, x: 0, y: 0, stashed: false

    visit campaign_path(map.campaign)
    wait_for_connection
    click_and_move_token(token, by: { x: 50, y: 50 })

    expect(page).to have_token_with_data(token, "x", 200)
    expect(page).to have_token_with_data(token, "y", 200)
  end

  it "moves the token for other users" do
    map = create :map, :current, zoom: 2
    token = create :token, map: map, x: 0, y: 0, stashed: false

    visit campaign_path(map.campaign)
    wait_for_connection
    using_session "other user" do
      visit campaign_path(map.campaign)
      wait_for_connection
    end

    click_and_move_token(token, by: { x: 50, y: 50 })

    using_session "other user" do
      expect(page).to have_token_with_data(token, "x", 50)
      expect(page).to have_token_with_data(token, "y", 50)
    end
  end
end
