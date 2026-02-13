# frozen_string_literal: true

require "spec_helper"

# Set Rails environment
ENV["RAILS_ENV"] = "test"

# Load the Rails application
require_relative "sandbox/config/environment"

# Require ViewComponent test helpers
require "view_component"
require "view_component/test_helpers"
require "capybara/rspec"

# Load the gem (auto-loads all components)
require "stimulus_plumbers"

# RSpec configuration
RSpec.configure do |config|
  # Include ViewComponent test helpers
  config.include ViewComponent::TestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component

  # Set up a basic controller for rendering
  config.before(:each, type: :component) do
    @vc_test_controller = Class.new(ActionController::Base).new
    @vc_test_controller.request = ActionDispatch::TestRequest.create
    @vc_test_controller.response = ActionDispatch::Response.new
  end
end
