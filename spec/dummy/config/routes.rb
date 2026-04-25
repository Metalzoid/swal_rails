# frozen_string_literal: true

Rails.application.routes.draw do
  root "pages#index"
  get  "/plain", to: "pages#plain"
  get  "/notice", to: "pages#show_notice"
  get  "/alert",  to: "pages#show_alert"
  get  "/custom_flash", to: "pages#show_custom"
  get  "/stacked_errors", to: "pages#show_stacked"
  get  "/sequential_errors", to: "pages#show_sequential"
  get  "/confirm", to: "pages#confirm_page"
  get  "/chain",   to: "pages#chain_page"
  delete "/items/:id", to: "pages#destroy", as: :item
  delete "/items_chain/:id", to: "pages#destroy_chain", as: :item_chain
end
