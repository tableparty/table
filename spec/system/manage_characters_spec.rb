require "rails_helper"

RSpec.describe "manage characters", type: :system do
  it "lists characters" do
    campaign = create(:campaign)
    character = create(:character, campaign: campaign)

    visit campaign_path(campaign, as: campaign.user)

    expect(page).to have_character(character)
  end

  it "can create a character" do
    user = create(:user)
    campaign = create(:campaign, user: user)
    map = create(:map, campaign: campaign)
    campaign.update(current_map: map)

    visit campaign_path(campaign, as: user)
    click_on "New Character"
    fill_in "Name", with: "Uxil"
    attach_file "Image", file_fixture("uxil.jpeg")
    click_on "Create Character"

    character = campaign.characters.last
    expect(page).to have_character(character)
    expect(page).to have_token(character.tokens.first)
  end

  it "can edit a character" do
    campaign = create(:campaign)
    character = create(:character, campaign: campaign)

    visit campaign_path(campaign, as: campaign.user)
    click_on character.name
    fill_in "Name", with: "New Name"
    click_on "Update Character"

    expect(page).to have_character(character)
  end

  it "can delete a character" do
    campaign = create(:campaign)
    character = create(:character, campaign: campaign)

    visit campaign_path(campaign, as: campaign.user)
    click_on character.name
    accept_confirm do
      click_on "Delete #{character.name}"
    end

    expect(page).not_to have_character(character)
  end

  def have_character(character)
    have_css ".character[data-character-id='#{character.id}']"
  end
end
