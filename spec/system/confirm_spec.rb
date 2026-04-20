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

  it "merges data-swal-options JSON into the Swal call" do
    # Default icon is 'warning'; the styled button overrides to 'error' and
    # changes the confirm button text.
    visit "/confirm"
    find("#delete-styled-btn").click

    expect(page).to have_css(".swal2-popup", wait: 5)
    expect(page).to have_css(".swal2-icon-error")
    expect(page).to have_button("Nuke")
  end

  it "treats a Hash message (JSON-encoded by Rails) as SA2 options" do
    # Covers both turbo_confirm: { ... } and swal_confirm: { ... } — same
    # confirmDialog code path parses the JSON message.
    visit "/confirm"
    find("#delete-hash-msg-btn").click

    expect(page).to have_css(".swal2-popup", wait: 5)
    expect(page).to have_css(".swal2-icon-info")
    expect(page).to have_button("Yep")
  end
end
