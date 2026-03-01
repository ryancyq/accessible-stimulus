# frozen_string_literal: true

require "test_helper"

class PopoverComponentTest < ComponentTest
  # rendering
  def test_renders_basic_popover_in_template_when_interactive
    render_inline(PopoverComponent.new(interactive: true)) { "Popover content" }

    assert_includes rendered_content, "<template>"
  end

  def test_renders_popover_content_directly_when_not_interactive
    render_inline(PopoverComponent.new(interactive: false)) { "Popover content" }

    assert_text "Popover content"
    refute_selector "template"
  end

  def test_renders_with_custom_attributes
    render_inline(PopoverComponent.new(id: "user-menu", class: "dropdown"))

    assert_selector "#user-menu.dropdown"
  end

  def test_renders_with_activator_slot
    component = PopoverComponent.new
    component.with_activator { "Click me" }
    render_inline(component)

    assert_text "Click me"
  end

  def test_renders_with_button_slot
    component = PopoverComponent.new
    component.with_button { "Open" }
    render_inline(component)

    assert_text "Open"
  end

  # interactive mode
  def test_defaults_to_interactive_true
    assert PopoverComponent.new.interactive
  end

  def test_can_be_set_to_non_interactive
    refute PopoverComponent.new(interactive: false).interactive
  end

  def test_accepts_interactive_true_explicitly
    assert PopoverComponent.new(interactive: true).interactive
  end

  # scrollable mode
  def test_defaults_to_scrollable_false
    refute PopoverComponent.new.scrollable
  end

  def test_can_be_set_to_scrollable
    assert PopoverComponent.new(scrollable: true).scrollable
  end

  def test_accepts_scrollable_false_explicitly
    refute PopoverComponent.new(scrollable: false).scrollable
  end

  # accessibility
  def test_renders_with_data_attributes_for_stimulus
    component = PopoverComponent.new(
      data: { controller: "popover", action: "click->popover#toggle" }
    )
    render_inline(component)

    assert_selector '[data-controller="popover"]'
    assert_selector '[data-action="click->popover#toggle"]'
  end

  def test_supports_aria_attributes
    component = PopoverComponent.new(aria: { haspopup: "true", expanded: "false" })
    render_inline(component)

    assert_selector '[aria-haspopup="true"]'
    assert_selector '[aria-expanded="false"]'
  end

  # combined options
  def test_handles_both_interactive_and_scrollable
    component = PopoverComponent.new(interactive: true, scrollable: true)

    assert component.interactive
    assert component.scrollable
  end

  def test_handles_non_interactive_and_scrollable
    component = PopoverComponent.new(interactive: false, scrollable: true)

    refute component.interactive
    assert component.scrollable
  end
end
