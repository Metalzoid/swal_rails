# frozen_string_literal: true

SwalRails::Engine.routes.draw do
  get "suppressions", to: "suppressions#index"
  post "suppressions", to: "suppressions#create"
  delete "suppressions", to: "suppressions#destroy"
end
