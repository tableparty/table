require "rails_helper"

RSpec.describe "Visitor signs up", type: :system do
  it "by navigating to the page" do
    visit sign_in_path

    click_link I18n.t("sessions.form.sign_up")

    expect(page).to have_current_path sign_up_path, ignore_query: true
  end

  it "with valid email, password and code" do
    sign_up_with "Name", "valid@example.com", "password", ENV["SIGN_UP_CODE"]

    expect_user_to_be_signed_in
  end

  it "tries with invalid email" do
    sign_up_with "Name", "invalid_email", "password", ENV["SIGN_UP_CODE"]

    expect_user_to_be_signed_out
  end

  it "tries with blank password" do
    sign_up_with "Name", "valid@example.com", "", ENV["SIGN_UP_CODE"]

    expect_user_to_be_signed_out
  end

  it "tries with blank name" do
    sign_up_with "", "valid@example.com", "password", ENV["SIGN_UP_CODE"]

    expect_user_to_be_signed_out
  end

  it "tries with wrong code" do
    sign_up_with "Name", "valid@example.com", "password", "howaboutthis?"

    expect(page).to have_content("Incorrect sponsor code")
    expect_user_to_be_signed_out
  end
end
