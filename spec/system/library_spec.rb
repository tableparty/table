require "rails_helper"

RSpec.describe "manage creatures", type: :system do
  it "lists creatures" do
    map = create(:map)
    campaign = map.campaign
    campaign.update(current_map: map)
    creature = create(:creature, campaign: campaign)

    visit campaign_path(campaign, as: campaign.user)
    view_library

    expect(page).to have_creature(creature)
  end

  it "can edit a creature" do
    map = create(:map)
    campaign = map.campaign
    creature = create(:creature, campaign: campaign)
    campaign.update(current_map: map)

    visit campaign_path(campaign, as: campaign.user)
    view_library
    find("[data-creature-id='#{creature.id}']").hover
    click_on "Edit"
    fill_in "Name", with: "New Name"
    click_on "Update Creature"
    view_library

    expect(page).to have_creature(creature)
  end

  it "can delete a creature" do
    map = create(:map)
    campaign = map.campaign
    creature = create(:creature, campaign: campaign)
    campaign.update(current_map: map)

    visit campaign_path(campaign, as: campaign.user)
    view_library
    find("[data-creature-id='#{creature.id}']").hover
    click_on "Edit"
    accept_confirm do
      click_on "Delete #{creature.name}"
    end
    view_library

    expect(page).not_to have_creature(creature)
  end

  it "can add a creature to the current map" do
    map = create(:map)
    campaign = map.campaign
    creature = create(:creature, campaign: campaign)
    campaign.update(current_map: map)

    visit campaign_path(campaign, as: campaign.user)
    view_library
    click_on "Add to map"

    expect(find(".current-map__token-drawer"))
      .to have_token(creature.tokens.first)
  end

  it "lists characters" do
    map = create(:map)
    campaign = map.campaign
    campaign.update(current_map: map)
    character = create(:character, campaign: campaign)

    visit campaign_path(campaign, as: campaign.user)
    view_library

    expect(page).to have_character(character)
  end

  it "can edit a character" do
    map = create(:map)
    campaign = map.campaign
    character = create(:character, campaign: campaign)
    campaign.update(current_map: map)

    visit campaign_path(campaign, as: campaign.user)
    view_library
    find("[data-character-id='#{character.id}']").hover
    click_on "Edit"
    fill_in "Name", with: "New Name"
    click_on "Update Character"
    view_library

    expect(page).to have_character(character)
  end

  it "can delete a character" do
    map = create(:map)
    campaign = map.campaign
    character = create(:character, campaign: campaign)
    campaign.update(current_map: map)
    token = character.tokens.first

    visit campaign_path(campaign, as: campaign.user)
    view_library
    find("[data-character-id='#{character.id}']").hover
    click_on "Edit"
    accept_confirm do
      click_on "Delete #{character.name}"
    end

    expect(map_element(map)).not_to have_token(token)
  end

  it "can add a character to the current map" do
    map = create(:map)
    campaign = map.campaign
    character = create(:character, campaign: campaign)
    campaign.update(current_map: map)

    visit campaign_path(campaign, as: campaign.user)
    view_library
    click_on "Add to map"

    expect(find(".current-map__token-drawer"))
      .to have_token(character.tokens.first)
  end

  def have_character(character)
    have_css "[data-character-id='#{character.id}']"
  end

  def have_creature(creature)
    have_css "[data-creature-id='#{creature.id}']"
  end

  def view_library
    wait_for_connection
    page.has_no_css?(".modal__background")
    click_on "New Token"
    find("label", text: "Library").click
  end
end
