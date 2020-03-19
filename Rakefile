# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be
# available to Rake.

require_relative "config/application"

Rails.application.load_tasks

if Rails.env.development? || Rails.env.test?
  require "rubocop/rake_task"

  RuboCop::RakeTask.new

  task default: :lint

  desc "Lint everything"
  task lint: "lint:ruby"

  namespace :lint do
    desc "Lint the ruby files everywhere"
    task ruby: :rubocop
  end
end
