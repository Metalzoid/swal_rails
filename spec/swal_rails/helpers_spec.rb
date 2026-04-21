# frozen_string_literal: true

require "action_view"
require "action_view/helpers"

RSpec.describe SwalRails::Helpers do
  let(:klass) do
    Class.new do
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::JavaScriptHelper
      include ActionView::Helpers::OutputSafetyHelper
      include SwalRails::Helpers

      attr_accessor :output_buffer, :flash

      def initialize = @flash = {}
    end
  end

  subject(:view) { klass.new }

  describe "#swal_config_meta_tag" do
    it "emits a meta tag with JSON payload" do
      tag = view.swal_config_meta_tag
      expect(tag).to include('name="swal-config"')
      expect(tag).to include("confirmMode")
    end
  end

  describe "#swal_flash_meta_tag" do
    it "returns nil when flash is empty" do
      expect(view.swal_flash_meta_tag).to be_nil
    end

    it "emits a JSON payload for non-empty flash" do
      view.flash = { "notice" => "Saved" }
      tag = view.swal_flash_meta_tag
      expect(tag).to include('name="swal-flash"')
      expect(tag).to include("Saved")
    end

    it "skips blank messages" do
      view.flash = { "notice" => "", "alert" => "Bad" }
      tag = view.swal_flash_meta_tag
      expect(tag).to include("Bad")
      expect(tag).not_to include("&quot;key&quot;:&quot;notice&quot;")
    end

    it "accepts a Hash as a per-request options override" do
      view.flash = { "notice" => { text: "Custom", icon: "star", timer: 5000 } }
      tag = view.swal_flash_meta_tag
      expect(tag).to include("&quot;text&quot;:&quot;Custom&quot;")
      expect(tag).to include("&quot;icon&quot;:&quot;star&quot;")
      expect(tag).to include("&quot;timer&quot;:5000")
    end

    it "wraps a plain string message as options: { text: ... }" do
      view.flash = { "notice" => "Saved" }
      tag = view.swal_flash_meta_tag
      expect(tag).to include("&quot;options&quot;:{&quot;text&quot;:&quot;Saved&quot;}")
    end

    it "returns nil when disabled by config" do
      SwalRails.configuration.flash_keys_as_meta = false
      view.flash = { "notice" => "Saved" }
      expect(view.swal_flash_meta_tag).to be_nil
    ensure
      SwalRails.configuration.flash_keys_as_meta = true
    end

    it "expands array messages into one entry per element" do
      view.flash = { "alert" => ["First", "Second", "", "Third"] }
      tag = view.swal_flash_meta_tag
      expect(tag).to include("First")
      expect(tag).to include("Second")
      expect(tag).to include("Third")
      # Each message gets its own {key,message} entry — three, not one stringified array.
      # Attribute is HTML-escaped (&quot;), so match the entity form.
      expect(tag.scan("&quot;key&quot;:&quot;alert&quot;").size).to eq(3)
    end

    it "accepts symbol keys and preserves them as strings" do
      view.flash = { notice: "Saved" }
      expect(view.swal_flash_meta_tag).to include("&quot;key&quot;:&quot;notice&quot;")
    end
  end

  describe "#swal_rails_meta_tags" do
    it "emits both tags joined into a single html_safe string" do
      view.flash = { "notice" => "Welcome" }
      out = view.swal_rails_meta_tags
      expect(out).to be_html_safe
      expect(out).to include('name="swal-config"')
      expect(out).to include('name="swal-flash"')
    end

    it "emits just the config tag when flash is empty" do
      out = view.swal_rails_meta_tags
      expect(out).to include('name="swal-config"')
      expect(out).not_to include('name="swal-flash"')
    end
  end

  describe "#swal_tag" do
    it "renders an ES module script" do
      out = view.swal_tag(title: "Hi", icon: "info")
      expect(out).to include('type="module"')
      expect(out).to include("Swal.fire")
      expect(out).to include('"title":"Hi"')
    end

    it "neutralizes a </script> breakout attempt in a string value" do
      out = view.swal_tag(title: "pwn</script><script>alert(1)</script>")
      expect(out).not_to include("</script><script>alert(1)")
      expect(out).to include('\u003c/script')
    end

    it "escapes U+2028 and U+2029 line terminators" do
      out = view.swal_tag(title: "line\u2028break\u2029end")
      expect(out).to include('\u2028')
      expect(out).to include('\u2029')
      expect(out).not_to include("\u2028")
      expect(out).not_to include("\u2029")
    end

    it "omits nonce=true silently when no CSP helper is present" do
      out = view.swal_tag({ title: "Hi" }, nonce: true)
      expect(out).to include('type="module"')
      expect(out).not_to include("nonce=")
    end

    it "propagates the CSP nonce when the helper is available" do
      csp_view = Class.new(klass) do
        def content_security_policy_nonce = "abc123"
      end.new
      out = csp_view.swal_tag({ title: "Hi" }, nonce: true)
      expect(out).to include('nonce="abc123"')
    end
  end

  describe "#swal_chain_tag" do
    it "renders an ES module script that imports chainDialogs" do
      out = view.swal_chain_tag([{ title: "A" }, { title: "B" }])
      expect(out).to include('type="module"')
      expect(out).to include('import { chainDialogs } from "swal_rails/chain"')
      expect(out).to include("chainDialogs(Swal,")
      expect(out).to include('[{"title":"A"},{"title":"B"}]')
    end

    it "wraps a single Hash step via Array()" do
      out = view.swal_chain_tag(title: "Solo")
      expect(out).to include('[{"title":"Solo"}]')
    end

    it "neutralizes a </script> breakout attempt inside a step" do
      out = view.swal_chain_tag([{ title: "pwn</script><script>alert(1)</script>" }])
      expect(out).not_to include("</script><script>alert(1)")
      expect(out).to include('\u003c/script')
    end

    it "preserves onConfirmed / onDenied nested sub-chains verbatim in the payload" do
      out = view.swal_chain_tag([
                                  { title: "Choice", onConfirmed: [{ title: "Yes branch" }],
                                    onDenied: [{ title: "No branch" }] }
                                ])
      expect(out).to include('"onConfirmed":[{"title":"Yes branch"}]')
      expect(out).to include('"onDenied":[{"title":"No branch"}]')
    end

    it "omits nonce=true silently when no CSP helper is present" do
      out = view.swal_chain_tag([{ title: "Hi" }], nonce: true)
      expect(out).to include('type="module"')
      expect(out).not_to include("nonce=")
    end

    it "propagates the CSP nonce when the helper is available" do
      csp_view = Class.new(klass) do
        def content_security_policy_nonce = "xyz789"
      end.new
      out = csp_view.swal_chain_tag([{ title: "Hi" }], nonce: true)
      expect(out).to include('nonce="xyz789"')
    end
  end

  describe "XSS hardening on meta tags" do
    it "html-escapes attribute payload for swal_flash_meta_tag" do
      view.flash = { "alert" => 'evil"><img src=x onerror=alert(1)>' }
      tag = view.swal_flash_meta_tag
      expect(tag).not_to match(/<img\s+src=x/)
      expect(tag).to include("&quot;")
    end

    it "html-escapes attribute payload for swal_config_meta_tag" do
      SwalRails.configuration.default_options = { title: 'a"><script>alert(1)</script>' }
      tag = view.swal_config_meta_tag
      expect(tag).not_to include("<script>alert(1)")
    ensure
      SwalRails.configuration.default_options = {}
    end
  end
end
