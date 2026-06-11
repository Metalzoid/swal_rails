# frozen_string_literal: true

require "rails_helper"

RSpec.describe SwalRails::TurboStreamHelper do
  subject(:tag_builder) { Turbo::Streams::TagBuilder.new(ActionView::Base.empty) }

  describe "#swal" do
    it "emits a swal turbo-stream with the given options" do
      out = tag_builder.swal({ icon: "info", title: "Hi" })
      expect(out).to include('<turbo-stream action="swal">')
      expect(out).to include('"icon":"info"')
      expect(out).to include('"title":"Hi"')
    end

    it "accepts the bare-keyword call form documented since 0.5.x" do
      # `swal(icon: "success", title: "OK", toast: true, timer: 3000)` — no
      # braces — must keep working; Ruby 3 kwarg separation would otherwise
      # route the hash to keywords and raise ArgumentError.
      out = tag_builder.swal(icon: "success", title: "OK", toast: true, timer: 3000)
      expect(out).to include('"icon":"success"')
      expect(out).to include('"title":"OK"')
      expect(out).to include('"toast":true')
      expect(out).to include('"timer":3000')
    end

    it "accepts bare keywords mixed with mute_key" do
      out = tag_builder.swal(icon: "info", title: "Hi", mute_key: "tips.welcome")
      expect(out).to include('"icon":"info"')
      expect(out).to include('"_muteKey":"tips.welcome"')
      expect(out).not_to include("mute_key")
    end

    it "merges _muteKey into the payload when mute_key is given" do
      out = tag_builder.swal({ icon: "info", title: "Hi" }, mute_key: "tips.welcome")
      expect(out).to include('"_muteKey":"tips.welcome"')
    end

    it "omits _muteKey when mute_key is not given" do
      out = tag_builder.swal({ icon: "info", title: "Hi" })
      expect(out).not_to include("_muteKey")
    end
  end

  describe "#swal_flash" do
    it "merges flash_map defaults for the key" do
      out = tag_builder.swal_flash(:notice, "Saved")
      expect(out).to include('"icon":"success"')
      expect(out).to include('"text":"Saved"')
    end

    it "applies overrides over the flash_map defaults" do
      out = tag_builder.swal_flash(:error, "Échec", timer: 0)
      expect(out).to include('"timer":0')
    end

    it "merges _muteKey into the payload when mute_key is given" do
      out = tag_builder.swal_flash(:notice, "Saved", mute_key: "posts.saved")
      expect(out).to include('"_muteKey":"posts.saved"')
    end
  end
end
