# frozen_string_literal: true

require "rails_helper"

# Exercises the mounted suppressions HTTP API end-to-end: routing, the
# require_owner! 401 gate (owner scoping / no-IDOR), status codes, and the
# missing-param 400. Preferences is stubbed — the dummy app has no
# ActiveRecord table — so this locks the HTTP contract without a DB.
# See suppressions_controller_spec for the unit-level current_owner guard.
RSpec.describe "SwalRails suppressions API", type: :request do
  let(:owner) { Object.new }

  describe "as a guest (no resolvable owner)" do
    it "returns 401 and never touches Preferences writes" do
      expect(SwalRails::Preferences).not_to receive(:suppress)
      expect(SwalRails::Preferences).not_to receive(:unsuppress)

      get "/swal_rails/suppressions"
      expect(response).to have_http_status(:unauthorized)

      post "/swal_rails/suppressions", params: { key: "posts.saved" }
      expect(response).to have_http_status(:unauthorized)

      delete "/swal_rails/suppressions", params: { key: "posts.saved" }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "as a resolved owner" do
    before do
      allow_any_instance_of(SwalRails::SuppressionsController)
        .to receive(:current_user).and_return(owner)
    end

    it "GET returns the owner's suppressed keys as JSON" do
      allow(SwalRails::Preferences).to receive(:suppressed_keys).with(owner).and_return(["posts.saved"])

      get "/swal_rails/suppressions"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq("keys" => ["posts.saved"])
    end

    it "POST suppresses the key for the resolved owner and returns 201" do
      expect(SwalRails::Preferences).to receive(:suppress).with(owner, "posts.saved")

      post "/swal_rails/suppressions", params: { key: "posts.saved" }

      expect(response).to have_http_status(:created)
    end

    it "DELETE unsuppresses the key for the resolved owner and returns 204" do
      expect(SwalRails::Preferences).to receive(:unsuppress).with(owner, "posts.saved")

      delete "/swal_rails/suppressions", params: { key: "posts.saved" }

      expect(response).to have_http_status(:no_content)
    end

    it "returns 400 when the key param is missing" do
      post "/swal_rails/suppressions"

      expect(response).to have_http_status(:bad_request)
    end
  end
end
