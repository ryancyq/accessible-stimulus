# frozen_string_literal: true

require "test_helper"

class DividerComponentTest < ComponentTest
  # rendering
  def test_renders_as_hr_element
    render_inline(DividerComponent.new)

    assert_selector "hr"
  end

  def test_renders_with_custom_content
    render_inline(DividerComponent.new) { "---" }

    assert_text "---"
  end

  def test_renders_with_custom_attributes
    render_inline(DividerComponent.new(class: "my-divider"))

    assert_selector "hr.my-divider"
  end

  def test_renders_with_id_attribute
    render_inline(DividerComponent.new(id: "section-divider"))

    assert_selector "hr#section-divider"
  end

  def test_renders_with_data_attributes
    render_inline(DividerComponent.new(data: { testid: "divider" }))

    assert_selector 'hr[data-testid="divider"]'
  end

  # accessibility
  def test_uses_semantic_hr_element
    render_inline(DividerComponent.new)

    assert_includes rendered_content, "<hr"
  end

  def test_is_recognized_by_screen_readers_as_separator
    render_inline(DividerComponent.new)

    assert_selector "hr"
  end

  # integration with ContainerComponent
  def test_delegates_to_container_component_with_hr_tag
    render_inline(DividerComponent.new)

    assert_selector "hr"
  end

  def test_passes_attributes_through_to_container_component
    render_inline(DividerComponent.new(class: "thick-divider", data: { type: "major" }))

    assert_selector "hr.thick-divider"
    assert_selector 'hr[data-type="major"]'
  end
end
