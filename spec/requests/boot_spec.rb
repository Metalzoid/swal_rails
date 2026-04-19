# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dummy app boots", type: :request do
  it "renders the home page with swal meta tags" do
    get "/"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('name="swal-config"')
  end

  it "includes flash meta tag after a redirect" do
    get "/notice", params: {}, headers: {}, env: {}
    follow_redirect!
    expect(response.body).to include('name="swal-flash"')
    expect(response.body).to include("Profile updated")
  end
end
