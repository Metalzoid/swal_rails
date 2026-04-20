# frozen_string_literal: true

Rails.application.routes.draw do
  root "pages#index"
  get  "/plain", to: "pages#plain"
  get  "/notice", to: "pages#show_notice"
  get  "/alert",  to: "pages#show_alert"
  get  "/custom_flash", to: "pages#show_custom"
  get  "/confirm", to: "pages#confirm_page"
  delete "/items/:id", to: "pages#destroy", as: :item
end
