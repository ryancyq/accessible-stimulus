# frozen_string_literal: true

require "rails_helper"

RSpec.describe DividerComponent, type: :component do
  describe "rendering" do
    it "renders as hr element" do
      component = described_class.new
      render_inline(component)

      expect(page).to have_css("hr")
    end

    it "renders with custom content" do
      component = described_class.new
      render_inline(component) { "---" }

      expect(page).to have_text("---")
    end

    it "renders with custom attributes" do
      component = described_class.new(class: "my-divider")
      render_inline(component)

      expect(page).to have_css("hr.my-divider")
    end

    it "renders with id attribute" do
      component = described_class.new(id: "section-divider")
      render_inline(component)

      expect(page).to have_css("hr#section-divider")
    end

    it "renders with data attributes" do
      component = described_class.new(data: { testid: "divider" })
      render_inline(component)

      expect(page).to have_css('hr[data-testid="divider"]')
    end
  end

  describe "accessibility" do
    it "uses semantic hr element" do
      component = described_class.new
      render_inline(component)

      html = rendered_content
      expect(html).to include("<hr")
    end

    it "is recognized by screen readers as separator" do
      component = described_class.new
      render_inline(component)

      # hr is semantically a thematic break/separator
      expect(page).to have_css("hr")
    end
  end

  describe "integration with ContainerComponent" do
    it "delegates to ContainerComponent with hr tag" do
      component = described_class.new
      render_inline(component)

      # Should render hr tag via ContainerComponent
      expect(page).to have_css("hr")
    end

    it "passes attributes through to ContainerComponent" do
      component = described_class.new(class: "thick-divider", data: { type: "major" })
      render_inline(component)

      expect(page).to have_css("hr.thick-divider")
      expect(page).to have_css('hr[data-type="major"]')
    end
  end
end
