# frozen_string_literal: true

Rails.application.routes.draw do
  root "pages#index"
  get  "/plain", to: "pages#plain"
  get  "/notice", to: "pages#notice"
  get  "/alert",  to: "pages#alert"
  get  "/confirm", to: "pages#confirm_page"
  delete "/items/:id", to: "pages#destroy", as: :item
end
