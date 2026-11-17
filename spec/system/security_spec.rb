# frozen_string_literal: true

require "rails_helper"

# Non-regression for the 0.6.0 security fixes. Each scenario injects
# PagesController::XSS_PAYLOAD, whose onerror paints a red #pwned banner.
#
# `SHOTS=<dir> bundle exec rspec spec/system/security_spec.rb` also saves a
# screenshot per scenario under tmp/screenshots/<dir>/ (before/after proofs).
RSpec.describe "Security", type: :system, js: true do
  let(:payload) { PagesController::XSS_PAYLOAD }

  def shot(name)
    dir = ENV.fetch("SHOTS", nil)
    return unless dir

    sleep 1 # let a pending onerror or redirect land in the picture
    path = File.expand_path("../../tmp/screenshots/#{dir}/#{name}.png", __dir__)
    page.save_screenshot(path) # rubocop:disable Lint/Debugger -- opt-in proof, not a leftover
  end

  it "renders a String confirm message as text" do
    visit "/security"
    find("#confirm-xss").click
    expect(page).to have_css(".swal2-popup")
    shot("1-confirm-message")

    expect(page).to have_css(".swal2-title", text: "<img")
    expect(page).to have_no_css("#pwned")
  end

  it "renders the inputExpected value of a typed confirmation as text" do
    visit "/security"
    find("#typed-xss").click
    find(".swal2-input").set("wrong")
    find(".swal2-confirm").click
    expect(page).to have_css(".swal2-validation-message")
    shot("2-input-expected")

    expect(page).to have_css(".swal2-validation-message", text: "<img")
    expect(page).to have_no_css("#pwned")
  end

  it "escapes the HTML options of a Hash flash coming from params" do
    visit "/reflect_flash?#{{ msg: { html: payload } }.to_query}"
    expect(page).to have_css(".swal2-toast")
    shot("3-flash-hash")

    expect(page).to have_css(".swal2-html-container", text: "<img")
    expect(page).to have_no_css("#pwned")
  end

  it "asks for confirmation again on every click" do
    visit "/security"
    find("#confirm-twice").click
    find(".swal2-confirm").click
    expect(page).to have_css("#count", text: "1")
    expect(page).to have_no_css(".swal2-popup")

    find("#confirm-twice").click
    shot("4a-second-click")

    expect(page).to have_css(".swal2-popup")
    expect(page).to have_css("#count", text: "1")
  end

  it "submits a confirmed <form data-swal-confirm> from its submit button" do
    visit "/security"
    find("#confirm-form-btn").click
    find(".swal2-confirm").click
    shot("4b-form-submit")

    expect(page).to have_content("Deleted item #77")
  end
end
