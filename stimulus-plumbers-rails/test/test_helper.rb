# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
require_relative "sandbox/config/environment"

require "minitest/autorun"
require "minitest/mock"
require "view_component"
require "view_component/test_helpers"
require "capybara/minitest"
require "stimulus_plumbers"

class ComponentTest < Minitest::Test
  include ViewComponent::TestHelpers
  include Capybara::Minitest::Assertions

  def setup
    @vc_test_controller = Class.new(ActionController::Base).new
    @vc_test_controller.request = ActionDispatch::TestRequest.create
    @vc_test_controller.response = ActionDispatch::Response.new
  end

  def teardown
    Capybara.reset_sessions!
  end
end
