# frozen_string_literal: true

require "application_system_test_case"

class ContainerComponentSystemTest < ApplicationSystemTestCase
  BASE = "/rails/view_components/container_component"

  def test_default_passes_wcag
    visit "#{BASE}/default"
    assert_accessible
  end
end
