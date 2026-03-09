# frozen_string_literal: true

Rails.application.routes.draw do
  mount ViewComponent::Engine, at: "/"

  scope "/form", controller: "form" do
    get :sign_up
    get :field_error
  end
end
