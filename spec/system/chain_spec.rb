# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Chain integration", type: :system, js: true do
  # SA2 focuses the Cancel button by default in our chain defaults. Click the
  # button directly rather than pressing Escape so we're explicit about the
  # dismissal path (isDismissed).
  def click_swal(label)
    within(".swal2-actions") { click_on(label) }
  end

  describe "linear chain" do
    it "aborts on Cancel at step 1 — no navigation, no second popup" do
      visit "/chain"
      find("#chain-linear-btn").click

      expect(page).to have_css(".swal2-popup", wait: 5)
      expect(page).to have_content("Delete step 1?")
      click_swal("Cancel")

      expect(page).to have_css("#chain-title", text: "Chain page")
      expect(page).to have_no_css(".swal2-popup", wait: 2)
    end

    it "aborts on Cancel at step 2" do
      visit "/chain"
      find("#chain-linear-btn").click

      expect(page).to have_content("Delete step 1?", wait: 5)
      click_swal("OK")
      expect(page).to have_content("Really delete step 2?", wait: 5)
      click_swal("Cancel")

      expect(page).to have_css("#chain-title", text: "Chain page")
      expect(page).to have_no_content("Chained delete")
    end

    it "fires the action when every step is confirmed" do
      visit "/chain"
      find("#chain-linear-btn").click

      expect(page).to have_content("Delete step 1?", wait: 5)
      click_swal("OK")
      expect(page).to have_content("Really delete step 2?", wait: 5)
      click_swal("OK")

      # Landing page shows the flash toast from #destroy_chain.
      expect(page).to have_content("Chained delete #1", wait: 5)
    end

    it "requires the expected text on typed confirmation steps" do
      visit "/chain"
      find("#chain-typed-btn").click

      expect(page).to have_content("Delete step 1?", wait: 5)
      click_swal("OK")
      expect(page).to have_content("Really delete step 2?", wait: 5)
      click_swal("OK")
      expect(page).to have_content("Type DELETE to confirm", wait: 5)

      click_swal("OK")
      expect(page).to have_css(".swal2-validation-message", wait: 5)
      expect(page).to have_css("#chain-title", text: "Chain page")

      find(".swal2-input", wait: 5).set("DELETE")
      click_swal("OK")

      expect(page).to have_content("Chained delete #4", wait: 5)
    end
  end

  describe "onDenied sub-chain" do
    it "runs the sub-chain when Deny is pressed, then fires the action on confirm" do
      visit "/chain"
      find("#chain-denied-btn").click

      expect(page).to have_content("Delete or just hide?", wait: 5)
      click_swal("Hide instead")

      expect(page).to have_content("Confirm hide?", wait: 5)
      click_swal("OK")

      expect(page).to have_content("Chained delete #2", wait: 5)
    end

    it "aborts when the Deny sub-chain itself is cancelled" do
      visit "/chain"
      find("#chain-denied-btn").click

      expect(page).to have_content("Delete or just hide?", wait: 5)
      click_swal("Hide instead")
      expect(page).to have_content("Confirm hide?", wait: 5)
      click_swal("Cancel")

      expect(page).to have_no_content("Chained delete")
    end
  end

  describe "onConfirmed sub-chain" do
    it "replaces the remainder of the outer chain when Confirm is pressed" do
      visit "/chain"
      find("#chain-confirmed-btn").click

      expect(page).to have_content("Admin path or user path?", wait: 5)
      click_swal("Admin")
      expect(page).to have_content("Admin confirmation 1", wait: 5)
      click_swal("OK")
      expect(page).to have_content("Admin confirmation 2", wait: 5)
      click_swal("OK")

      # The "user step" must NOT appear — the onConfirmed branch replaced it.
      expect(page).to have_no_content("User step")
      expect(page).to have_content("Chained delete #3", wait: 5)
    end
  end
end
