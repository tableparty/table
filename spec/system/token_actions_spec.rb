require "rails_helper"

RSpec.describe "token actions", type: :system do
  it "can select multiple tokens" do
    map = create :map, :current
    token_one = create :token, map: map, stashed: false
    token_two = create :token, map: map, stashed: false

    visit campaign_path(map.campaign, as: map.campaign.user)
    wait_for_connection

    shift_click token_element(token_one)
    shift_click token_element(token_two)

    expect(token_element(token_one)["data-selected"]).to be_present
    expect(token_element(token_two)["data-selected"]).to be_present
  end

  it "can use the keyboard to select tokens" do
    map = create :map, :current
    token_one = create :token, map: map, stashed: false
    token_two = create :token, map: map, stashed: false

    visit campaign_path(map.campaign, as: map.campaign.user)
    wait_for_connection

    page.find("body").send_keys :right
    expect(token_element(token_one)["data-selected"]).to be_present
    expect(token_element(token_two)["data-selected"]).not_to be_present

    page.find("body").send_keys :right
    expect(token_element(token_one)["data-selected"]).not_to be_present
    expect(token_element(token_two)["data-selected"]).to be_present

    page.find("body").send_keys :right
    expect(token_element(token_one)["data-selected"]).to be_present
    expect(token_element(token_two)["data-selected"]).not_to be_present

    page.find("body").send_keys :left
    expect(token_element(token_one)["data-selected"]).not_to be_present
    expect(token_element(token_two)["data-selected"]).to be_present
  end

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
    it "moves tokens from the map to the drawer by clicking the button" do
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
      expect_token_actions_disabled
    end

    it "moves tokens from the map to the drawer with the keyboard shortcut" do
      map = create :map, :current
      token = create :token, map: map, stashed: false

      visit campaign_path(map.campaign, as: map.campaign.user)
      wait_for_connection
      token_element = token_element(token)
      token_element.click
      page.find("body").send_keys "s"
      open_token_drawer

      expect(token_drawer).to have_token(token)
      expect(map_element(map)).not_to have_token(token)
      expect_token_actions_disabled
    end

    it "moves multiple tokens from the map to the drawer" do
      map = create :map, :current
      token_one = create :token, map: map, stashed: false
      token_two = create :token, map: map, stashed: false

      visit campaign_path(map.campaign, as: map.campaign.user)
      wait_for_connection
      shift_click token_element(token_one)
      shift_click token_element(token_two)
      click_on "Stash"
      open_token_drawer

      expect(token_drawer).to have_token(token_one)
      expect(token_drawer).to have_token(token_two)
      expect(map_element(map)).not_to have_token(token_one)
      expect(map_element(map)).not_to have_token(token_two)
      expect_token_actions_disabled
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
    it "deletes the token from the map by clicking the button" do
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
      expect_token_actions_disabled
    end

    it "deletes the token from the map with the keyboard shortcut" do
      map = create :map, :current
      token = create :token, map: map, stashed: false

      visit campaign_path(map.campaign, as: map.campaign.user)
      wait_for_connection
      token_element = token_element(token)
      token_element.click
      accept_confirm do
        page.find("body").send_keys :delete
      end
      open_token_drawer

      expect(token_drawer).not_to have_token(token)
      expect(map_element(map)).not_to have_token(token)
      expect(Token.exists?(token.id)).not_to be true
      expect_token_actions_disabled
    end

    it "deletes multiple tokens from the map" do
      map = create :map, :current
      token_one = create :token, map: map, stashed: false
      token_two = create :token, map: map, stashed: false

      visit campaign_path(map.campaign, as: map.campaign.user)
      wait_for_connection
      shift_click token_element(token_one)
      shift_click token_element(token_two)
      accept_confirm do
        click_on "Delete"
      end
      open_token_drawer

      expect(token_drawer).not_to have_token(token_one)
      expect(token_drawer).not_to have_token(token_two)
      expect(map_element(map)).not_to have_token(token_one)
      expect(map_element(map)).not_to have_token(token_two)
      expect(Token.exists?(token_one.id)).not_to be true
      expect(Token.exists?(token_two.id)).not_to be true
      expect_token_actions_disabled
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
    page.find_all("[data-target='map--tokens.action']").each do |button|
      expect(button).not_to be_disabled
    end
  end

  def expect_token_actions_disabled
    expect(page.find_all("[data-target='map--tokens.action']")).to all(
      be_disabled
    )
  end
end
