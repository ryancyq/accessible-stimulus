# frozen_string_literal: true

require "test_helper"

class ContainerComponentTest < ComponentTest
  # rendering
  def test_renders_with_specified_tag
    render_inline(ContainerComponent.new(tag: :div)) { "Content" }

    assert_selector "div", text: "Content"
  end

  def test_renders_with_span_tag
    render_inline(ContainerComponent.new(tag: :span)) { "Inline content" }

    assert_selector "span", text: "Inline content"
  end

  def test_renders_with_section_tag
    render_inline(ContainerComponent.new(tag: :section)) { "Section content" }

    assert_selector "section", text: "Section content"
  end

  def test_renders_with_custom_attributes
    component = ContainerComponent.new(tag: :div, id: "container-1", class: "wrapper")
    render_inline(component) { "Content" }

    assert_selector "div#container-1.wrapper"
  end

  def test_renders_with_data_attributes
    component = ContainerComponent.new(
      tag:  :div,
      data: { controller: "example", action: "click->example#handle" }
    )
    render_inline(component)

    assert_selector '[data-controller="example"]'
    assert_selector '[data-action="click->example#handle"]'
  end

  def test_merges_multiple_classes
    render_inline(ContainerComponent.new(tag: :div, class: "class-1 class-2"))

    assert_selector "div.class-1.class-2"
  end

  # #call
  def test_wraps_content_in_specified_tag
    render_inline(ContainerComponent.new(tag: :article)) { "Article content" }

    assert_includes rendered_content, "<article"
    assert_includes rendered_content, "Article content"
    assert_includes rendered_content, "</article>"
  end

  # accessibility
  def test_preserves_semantic_html_tags
    render_inline(ContainerComponent.new(tag: :nav)) { "Navigation" }

    assert_selector "nav"
  end

  def test_allows_aria_attributes
    component = ContainerComponent.new(tag: :div, aria: { label: "Main content", role: "main" })
    render_inline(component)

    assert_selector '[aria-label="Main content"]'
  end
end
