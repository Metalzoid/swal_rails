# frozen_string_literal: true

require "rails_helper"

RSpec.describe SwalRails::SuppressionsController do
  describe "#current_owner" do
    subject(:controller) { described_class.new }

    it "returns nil (→ 401) instead of raising when the current-user method is undefined" do
      # Default current_user_method is :current_user, which a bare controller
      # (ActionController::Base, no auth gem) does not respond to. The guard
      # must degrade to guest, not raise NoMethodError (which would 500).
      expect { controller.send(:current_owner) }.not_to raise_error
      expect(controller.send(:current_owner)).to be_nil
    end

    it "returns nil when current_user_method is configured as nil" do
      SwalRails.configuration.current_user_method = nil
      expect { controller.send(:current_owner) }.not_to raise_error
      expect(controller.send(:current_owner)).to be_nil
    end

    it "resolves the owner when the configured method is available" do
      SwalRails.configuration.current_user_method = :current_account
      allow(controller).to receive(:current_account).and_return("acct-1")
      expect(controller.send(:current_owner)).to eq("acct-1")
    end
  end
end
