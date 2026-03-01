# frozen_string_literal: true

require "test_helper"

class AvatarComponentTest < ComponentTest
  # rendering
  def test_renders_with_name_only
    render_inline(AvatarComponent.new(name: "John Doe"))

    assert_selector '[aria-label="John Doe"]'
  end

  def test_renders_with_initials
    render_inline(AvatarComponent.new(name: "Jane Smith", initials: "JS"))

    assert_text "JS"
  end

  def test_renders_with_url
    render_inline(AvatarComponent.new(name: "John", url: "/avatar.jpg"))

    assert_includes rendered_content, "/avatar.jpg"
  end

  def test_renders_with_custom_attributes
    component = AvatarComponent.new(name: "Test User", id: "user-avatar", class: "custom-avatar")
    render_inline(component)

    assert_selector "#user-avatar.custom-avatar"
  end

  # accessibility
  def test_adds_aria_label_when_name_is_provided
    render_inline(AvatarComponent.new(name: "Alice Johnson"))

    assert_selector '[aria-label="Alice Johnson"]'
  end

  def test_does_not_add_aria_label_when_name_is_nil
    render_inline(AvatarComponent.new(initials: "AJ"))

    refute_selector "[aria-label]"
  end

  # #color_class
  def test_returns_first_color_in_range_when_no_name_or_initials
    component = AvatarComponent.new

    assert_equal component.theme.avatar_color_range.first, component.color_class
  end

  def test_consistently_returns_same_color_for_same_name
    component = AvatarComponent.new(name: "John Doe")

    assert_equal component.color_class, component.color_class
  end

  def test_returns_a_color_from_theme_color_range_for_a_given_name
    component = AvatarComponent.new(name: "Test")

    assert_includes component.theme.avatar_color_range, component.color_class
  end

  def test_returns_a_color_from_theme_color_range_based_on_initials_when_name_is_nil
    component = AvatarComponent.new(initials: "AB")

    assert_includes component.theme.avatar_color_range, component.color_class
  end

  def test_returns_the_resolved_css_class_for_an_explicit_color_key
    component = AvatarComponent.new(name: "John", color: :indigo)

    assert_equal component.theme.avatar_colors.fetch(:indigo), component.color_class
  end

  def test_uses_explicit_color_over_computed_color_from_name
    auto_component    = AvatarComponent.new(name: "John")
    colored_component = AvatarComponent.new(name: "John", color: :rose)

    refute_equal auto_component.color_class, colored_component.color_class
    assert_equal colored_component.theme.avatar_colors.fetch(:rose), colored_component.color_class
  end
end
