# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContainerComponent, type: :component do
  describe "rendering" do
    it "renders with specified tag" do
      component = described_class.new(tag: :div)
      render_inline(component) { "Content" }

      expect(page).to have_css("div", text: "Content")
    end

    it "renders with span tag" do
      component = described_class.new(tag: :span)
      render_inline(component) { "Inline content" }

      expect(page).to have_css("span", text: "Inline content")
    end

    it "renders with section tag" do
      component = described_class.new(tag: :section)
      render_inline(component) { "Section content" }

      expect(page).to have_css("section", text: "Section content")
    end

    it "renders with custom attributes" do
      component = described_class.new(
        tag:   :div,
        id:    "container-1",
        class: "wrapper"
      )
      render_inline(component) { "Content" }

      expect(page).to have_css("div#container-1.wrapper")
    end

    it "renders with data attributes" do
      component = described_class.new(
        tag:  :div,
        data: { controller: "example", action: "click->example#handle" }
      )
      render_inline(component)

      expect(page).to have_css('[data-controller="example"]')
      expect(page).to have_css('[data-action="click->example#handle"]')
    end

    it "merges multiple classes" do
      component = described_class.new(
        tag:   :div,
        class: "class-1 class-2"
      )
      render_inline(component)

      expect(page).to have_css("div.class-1.class-2")
    end
  end

  describe "#call" do
    it "wraps content in specified tag" do
      component = described_class.new(tag: :article)
      render_inline(component) { "Article content" }

      html = rendered_content
      expect(html).to include("<article")
      expect(html).to include("Article content")
      expect(html).to include("</article>")
    end
  end

  describe "accessibility" do
    it "preserves semantic HTML tags" do
      component = described_class.new(tag: :nav)
      render_inline(component) { "Navigation" }

      expect(page).to have_css("nav")
    end

    it "allows ARIA attributes" do
      component = described_class.new(
        tag:  :div,
        aria: { label: "Main content", role: "main" }
      )
      render_inline(component)

      expect(page).to have_css('[aria-label="Main content"]')
    end
  end
end
