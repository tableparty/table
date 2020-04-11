Rails.application.config.action_mailer.default_url_options = {
  host: ENV["APP_HOST"]
}
Rails.application.routes.default_url_options =
  Rails.application.config.action_mailer.default_url_options
