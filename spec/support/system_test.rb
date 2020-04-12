RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium_chrome_headless
  end
end

def wait_for_connection
  page.has_no_css?("[data-target='campaign.statusIndicator']")
end
