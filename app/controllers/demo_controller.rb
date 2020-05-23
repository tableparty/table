class DemoController < ApplicationController
  def show
    if campaign
      render "campaigns/show", locals: { campaign: campaign }, layout: "demo"
    else
      head :ok
    end
  end

  private

  def campaign
    user&.campaigns&.first
  end

  def user
    User.where(email: demo_email).first
  end

  def demo_email
    "#{ENV.fetch('DEMO_SECRET')}@example.com"
  end
end
