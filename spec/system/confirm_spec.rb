# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Confirm integration", type: :system, js: true do
  it "intercepts a data-swal-confirm click with a Swal modal" do
    visit "/confirm"
    find("#delete-btn").click

    expect(page).to have_css(".swal2-popup", wait: 5)
    expect(page).to have_content("Really delete?")
  end

  it "cancels the action when user dismisses the modal" do
    visit "/confirm"
    find("#delete-btn").click
    within(".swal2-actions") { click_on("Cancel") }

    expect(page).to have_css("#confirm-title", text: "Confirm page")
    expect(page).not_to have_content("Deleted item")
  end
end
