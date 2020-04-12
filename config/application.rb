require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Table
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified
    # here. Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.generators do |generators|
      # Default primary keys to uuids
      generators.orm :active_record, primary_key_type: :uuid
    end

    config.to_prepare do
      Clearance::PasswordsController.layout "sessions"
      Clearance::SessionsController.layout "sessions"
      Clearance::UsersController.layout "sessions"
    end
  end
end
