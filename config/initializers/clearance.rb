Clearance.configure do |config|
  config.mailer_sender = ENV["SUPPORT_EMAIL"]
  config.rotate_csrf_on_sign_in = true
  config.routes = false
end
