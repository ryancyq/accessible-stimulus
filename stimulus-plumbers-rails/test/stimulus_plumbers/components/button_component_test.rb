# frozen_string_literal: true

require "test_helper"

class ButtonComponentTest < ComponentTest
  # rendering
  def test_renders_basic_button
    render_inline(ButtonComponent.new) { "Click me" }

    assert_text "Click me"
  end

  def test_renders_with_custom_attributes
    render_inline(ButtonComponent.new(id: "submit-btn", class: "primary")) { "Submit" }

    assert_selector "#submit-btn.primary"
  end

  def test_renders_with_prefix_slot
    component = ButtonComponent.new
    component.with_prefix { "<span>→</span>".html_safe }
    render_inline(component) { "Next" }

    assert_text "→"
    assert_text "Next"
  end

  def test_renders_with_suffix_slot
    component = ButtonComponent.new
    component.with_suffix { "<span>✓</span>".html_safe }
    render_inline(component) { "Save" }

    assert_text "Save"
    assert_text "✓"
  end

  # with url
  def test_renders_as_link_when_url_is_provided
    render_inline(ButtonComponent.new(url: "/dashboard")) { "Go to Dashboard" }

    assert_selector 'a[href="/dashboard"]', text: "Go to Dashboard"
  end

  def test_renders_external_link_with_target_blank
    render_inline(ButtonComponent.new(url: "https://example.com", external: true)) { "External" }

    assert_selector 'a[href="https://example.com"][target="_blank"]'
  end

  def test_does_not_add_target_blank_for_internal_links
    render_inline(ButtonComponent.new(url: "/internal", external: false)) { "Internal" }

    assert_selector 'a[href="/internal"]'
    refute_selector 'a[target="_blank"]'
  end

  # accessibility
  def test_is_keyboard_accessible
    render_inline(ButtonComponent.new) { "Button" }
    element = page.find_all("button, a").first

    refute_equal "-1", element[:tabindex]
  end

  def test_renders_semantic_button_by_default
    render_inline(ButtonComponent.new) { "Click" }

    assert_selector "button, a"
  end
end
