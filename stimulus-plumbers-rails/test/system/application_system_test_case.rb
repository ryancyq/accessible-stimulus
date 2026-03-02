# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
require_relative "../sandbox/config/environment"

require "minitest/autorun"
require "capybara/cuprite"
require "axe-capybara"
require "stimulus_plumbers"

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(app, window_size: [1200, 800], headless: true)
end

class ApplicationSystemTestCase < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  def setup
    Capybara.current_driver = :cuprite
    Capybara.app = Rails.application
  end

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
