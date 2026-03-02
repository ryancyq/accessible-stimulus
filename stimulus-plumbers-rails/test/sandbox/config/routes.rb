# frozen_string_literal: true

Rails.application.routes.draw do
  mount ViewComponent::Engine, at: "/"
end
