# frozen_string_literal: true

require "test_helper"

class CardComponentTest < ComponentTest
  # rendering
  def test_renders_basic_card_with_content
    render_inline(CardComponent.new) { "Card content" }

    assert_text "Card content"
  end

  def test_renders_with_title
    render_inline(CardComponent.new(title: "My Card"))

    assert_text "My Card"
  end

  def test_renders_with_custom_attributes
    render_inline(CardComponent.new(id: "main-card", class: "elevated")) { "Content" }

    assert_selector "#main-card.elevated"
  end

  def test_renders_divided_card
    component = CardComponent.new(divided: true)
    render_inline(component)

    assert component.divided
  end

  # sections
  def test_renders_multiple_sections
    component = CardComponent.new
    component.with_section(title: "Section 1") { "Content 1" }
    component.with_section(title: "Section 2") { "Content 2" }
    render_inline(component)

    assert_text "Section 1"
    assert_text "Content 1"
    assert_text "Section 2"
    assert_text "Content 2"
  end

  # actions alignment
  def test_defaults_to_right_alignment
    assert_equal :right, CardComponent.new.actions_alignment
  end

  def test_accepts_right_alignment
    assert_equal :right, CardComponent.new(actions_alignment: :right).actions_alignment
  end

  def test_accepts_left_alignment
    assert_equal :left, CardComponent.new(actions_alignment: :left).actions_alignment
  end

  def test_defaults_to_left_for_invalid_alignment
    assert_equal :left, CardComponent.new(actions_alignment: :center).actions_alignment
  end

  # #default_divider
  def test_default_divider_returns_a_divider_component
    assert_instance_of DividerComponent, CardComponent.new.default_divider
  end

  # accessibility
  def test_uses_semantic_html_structure
    render_inline(CardComponent.new) { "Content" }

    assert_includes rendered_content, "<"
  end
end
