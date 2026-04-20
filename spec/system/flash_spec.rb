# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Flash integration", type: :system, js: true do
  it "shows a toast for flash[:notice]" do
    visit "/notice"
    expect(page).to have_css(".swal2-toast", wait: 5)
    expect(page).to have_content("Profile updated")
    expect(page).to have_css(".swal2-icon-success")
  end

  it "shows a modal for flash[:alert]" do
    visit "/alert"
    expect(page).to have_css(".swal2-popup", wait: 5)
    expect(page).to have_content("Could not save")
    expect(page).to have_css(".swal2-icon-error")
  end

  it "renders no swal popup on a page without flash" do
    visit "/"
    expect(page).to have_css("#title", text: "Home")
    expect(page).not_to have_css(".swal2-popup")
  end

  it "honors per-request Hash options, overriding flash_map defaults" do
    # flash_map[:notice] defaults to a success toast — the Hash form flips
    # it to a question-icon modal with no timer.
    visit "/custom_flash"
    expect(page).to have_css(".swal2-popup", wait: 5)
    expect(page).to have_content("Custom bam")
    expect(page).to have_css(".swal2-icon-question")
    expect(page).not_to have_css(".swal2-toast")
  end
end
