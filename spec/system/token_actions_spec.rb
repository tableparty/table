require "rails_helper"

RSpec.describe "token actions", type: :system do
  describe "when a token is selected" do
    it "enables token actions" do
      map = create :map, :current
      token = create :token, map: map, stashed: false

      visit campaign_path(map.campaign, as: map.campaign.user)
      wait_for_connection

      expect_token_actions_disabled

      token_element = token_element(token)
      token_element.click

      expect_token_actions_enabled

      token_element.click

      expect_token_actions_disabled
    end
  end

  describe "stash" do
    it "moves tokens from the map to the drawer" do
      map = create :map, :current
      token = create :token, map: map, stashed: false

      visit campaign_path(map.campaign, as: map.campaign.user)
      wait_for_connection
      token_element = token_element(token)
      token_element.click
      click_on "Stash"

      open_token_drawer
      expect(token_drawer).to have_token(token)
      expect(map_element(map)).not_to have_token(token)
    end

    it "hides the token for other users" do
      map = create :map, :current
      token = create :token, map: map, stashed: false

      visit campaign_path(map.campaign, as: map.campaign.user)
      wait_for_connection
      using_session "other user" do
        visit campaign_path(map.campaign)
        wait_for_connection
      end

      token_element = token_element(token)
      token_element.click
      click_on "Stash"

      using_session "other user" do
        expect(page).not_to have_css(
          ".token[data-token-id='#{token.to_param}']"
        )
      end
    end
  end

  describe "delete" do
    it "deletes the token from the map" do
      map = create :map, :current
      token = create :token, map: map, stashed: false

      visit campaign_path(map.campaign, as: map.campaign.user)
      wait_for_connection
      token_element = token_element(token)
      token_element.click
      accept_confirm do
        click_on "Delete"
      end

      open_token_drawer
      expect(token_drawer).not_to have_token(token)
      expect(map_element(map)).not_to have_token(token)
      expect(Token.exists?(token.id)).not_to be true
    end

    it "deletes the token for other users" do
      map = create :map, :current
      token = create :token, map: map, stashed: false

      visit campaign_path(map.campaign, as: map.campaign.user)
      wait_for_connection
      using_session "other user" do
        visit campaign_path(map.campaign)
        wait_for_connection
      end

      token_element = token_element(token)
      token_element.click
      accept_confirm do
        click_on "Delete"
      end

      using_session "other user" do
        expect(page).not_to have_css(
          ".token[data-token-id='#{token.to_param}']"
        )
      end
    end
  end

  def expect_token_actions_enabled
    expect(page).to have_css(
      "[data-target='map--tokens.actions'].enabled"
    )
    buttons = page.find_all("[data-target='map--tokens.action']")
    buttons.each do |button|
      expect(button).not_to be_disabled
    end
  end

  def expect_token_actions_disabled
    expect(page).not_to have_css(
      "[data-target='map--tokens.actions'].enabled"
    )
    buttons = page.find_all("[data-target='map--tokens.action']")
    expect(buttons).to all(be_disabled)
  end
end
