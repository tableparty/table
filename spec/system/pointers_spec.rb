require "rails_helper"

RSpec.describe "pointers", type: :system do
  it "puts a pointer on the map" do
    map = create :map
    map.campaign.update(current_map: map)
    visit campaign_path(map.campaign)
    wait_for_connection
    element = map_element(map)
    alt_click_at(element, middle_of(element))
    expect(page).to have_css(".pointer")
  end

  it "shows pointer to other users" do
    map = create :map
    map.campaign.update(current_map: map)
    visit campaign_path(map.campaign)
    wait_for_connection

    using_session "other user" do
      visit campaign_path(map.campaign)
      wait_for_connection
    end

    element = map_element(map)
    alt_click_at(element, middle_of(element))

    using_session "other user" do
      expect(page).to have_css(".pointer")
    end
  end
end
