Rails.application.config.action_mailer.default_url_options = {
  host: ENV["HOST"]
}
Rails.application.routes.default_url_options =
  Rails.application.config.action_mailer.default_url_options
