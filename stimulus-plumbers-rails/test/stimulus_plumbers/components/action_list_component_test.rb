# frozen_string_literal: true

require "test_helper"

class ActionListComponentTest < ComponentTest
  # rendering
  def test_renders_list_with_items
    component = ActionListComponent.new
    component.with_item { "First action" }
    component.with_item { "Second action" }
    component.with_item { "Third action" }
    render_inline(component)

    assert_selector "div > ul > li", count: 3
    assert_text "First action"
    assert_text "Second action"
    assert_text "Third action"
  end

  def test_renders_items_as_buttons_when_no_url_is_provided
    component = ActionListComponent.new
    component.with_item { "Click me" }
    render_inline(component)

    assert_selector "button", text: "Click me"
  end

  def test_renders_with_custom_attributes
    component = ActionListComponent.new(
      id:    "my-action-list",
      class: "custom-class",
      data:  { testid: "action-list" }
    )
    component.with_item { "Action" }
    render_inline(component)

    assert_selector "div#my-action-list.custom-class"
    assert_selector '[data-testid="action-list"]'
  end

  def test_renders_multiple_sections_with_titles_and_dividers
    component = ActionListComponent.new
    component.with_section(title: "Section 1") do |section|
      section.with_item { "Action 1.1" }
      section.with_item { "Action 1.2" }
    end
    component.with_section(title: "Section 2") do |section|
      section.with_item { "Action 2.1" }
      section.with_item { "Action 2.2" }
    end
    render_inline(component)

    assert_selector "li > div", count: 2
    assert_selector "p", text: "Section 1"
    assert_selector "p", text: "Section 2"
    assert_selector "div > ul", count: 2
    assert_selector "hr", count: 1
    assert_text "Action 1.1"
    assert_text "Action 2.2"
  end

  def test_renders_sections_without_titles
    component = ActionListComponent.new
    component.with_section { |s| s.with_item { "Action 1" } }
    component.with_section { |s| s.with_item { "Action 2" } }
    render_inline(component)

    refute_selector "p"
    assert_selector "li > div", count: 2
  end

  def test_does_not_render_divider_for_single_section
    component = ActionListComponent.new
    component.with_section(title: "First") { |s| s.with_item { "Action 1" } }
    render_inline(component)

    refute_selector "hr"
  end

  def test_renders_mixed_sections_and_items_with_divider
    component = ActionListComponent.new
    component.with_section(title: "Section") { |s| s.with_item { "Section action" } }
    component.with_item { "Standalone action" }
    render_inline(component)

    assert_selector "hr", count: 1
    assert_text "Section action"
    assert_text "Standalone action"
  end

  def test_renders_custom_divider_component
    component = ActionListComponent.new
    component.with_divider(class: "custom-divider") { "---" }
    component.with_section(title: "First") { |s| s.with_item { "Action 1" } }
    component.with_section(title: "Second") { |s| s.with_item { "Action 2" } }
    render_inline(component)

    assert_selector "hr.custom-divider"
    assert_text "---"
  end

  # accessibility
  def test_uses_semantic_list_markup
    component = ActionListComponent.new
    component.with_item { "Action 1" }
    component.with_item { "Action 2" }
    render_inline(component)

    assert_selector "ul > li", count: 2
  end

  def test_renders_items_as_links_when_url_is_provided
    component = ActionListComponent.new
    component.with_section do |section|
      section.with_item(url: "/path") { "Go somewhere" }
      section.with_item(url: "https://example.com", external: true) { "External link" }
    end
    render_inline(component)

    assert_selector "a[href='/path']", text: "Go somewhere"
    assert_selector 'a[target="_blank"]', text: "External link"
  end

  def test_uses_semantic_hr_dividers
    component = ActionListComponent.new
    component.with_section(title: "Section 1") { |s| s.with_item { "Action" } }
    component.with_section(title: "Section 2") { |s| s.with_item { "Action" } }
    render_inline(component)

    assert_selector "hr"
  end

  def test_maintains_keyboard_focusability
    component = ActionListComponent.new
    component.with_item { "Button action" }
    component.with_section { |s| s.with_item(url: "/home") { "Link action" } }
    render_inline(component)
    button = page.find("button")
    link   = page.find("a")

    refute_equal "-1", button[:tabindex]
    assert_predicate link[:href], :present?
  end

  def test_maintains_logical_reading_order
    component = ActionListComponent.new
    component.with_section(title: "Navigation") do |section|
      section.with_item { "Home" }
      section.with_item { "About" }
    end
    component.with_section(title: "Account") do |section|
      section.with_item { "Profile" }
      section.with_item { "Settings" }
    end
    render_inline(component)
    html      = rendered_content
    positions = %w[Navigation Home About Account Profile Settings].map { |text| html.index(text) }

    assert_equal positions.sort, positions
  end

  def test_preserves_item_order
    component = ActionListComponent.new
    component.with_item { "First" }
    component.with_item { "Second" }
    component.with_item { "Third" }
    render_inline(component)
    html      = rendered_content
    positions = %w[First Second Third].map { |text| html.index(text) }

    assert_equal positions.sort, positions
  end

  def test_supports_data_attributes_for_stimulus_controllers
    component = ActionListComponent.new(
      data: { controller: "action-list", action: "click->action-list#handleClick" }
    )
    component.with_item { "Action" }
    render_inline(component)

    assert_selector '[data-controller="action-list"]'
    assert_selector '[data-action="click->action-list#handleClick"]'
  end

  def test_does_not_remove_focus_outlines
    component = ActionListComponent.new
    component.with_item { "Focusable action" }
    render_inline(component)
    button       = page.find("button")
    inline_style = button[:style].to_s

    refute_includes inline_style, "outline"
  end
end
