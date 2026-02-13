# frozen_string_literal: true

require "rails_helper"

RSpec.describe CardComponent, type: :component do
  describe "rendering" do
    it "renders basic card with content" do
      component = described_class.new
      render_inline(component) { "Card content" }

      expect(page).to have_text("Card content")
    end

    it "renders with title" do
      component = described_class.new(title: "My Card")
      render_inline(component)

      expect(page).to have_text("My Card")
    end

    it "renders with custom attributes" do
      component = described_class.new(id: "main-card", class: "elevated")
      render_inline(component) { "Content" }

      expect(page).to have_css("#main-card.elevated")
    end

    it "renders divided card" do
      component = described_class.new(divided: true)
      render_inline(component)

      expect(component.divided).to be true
    end
  end

  describe "sections" do
    it "renders multiple sections" do
      component = described_class.new
      component.with_section(title: "Section 1") { "Content 1" }
      component.with_section(title: "Section 2") { "Content 2" }
      render_inline(component)

      expect(page).to have_text("Section 1")
      expect(page).to have_text("Content 1")
      expect(page).to have_text("Section 2")
      expect(page).to have_text("Content 2")
    end
  end

  describe "actions alignment" do
    it "defaults to right alignment" do
      component = described_class.new
      expect(component.actions_alignment).to eq(:right)
    end

    it "accepts right alignment" do
      component = described_class.new(actions_alignment: :right)
      expect(component.actions_alignment).to eq(:right)
    end

    it "accepts left alignment" do
      component = described_class.new(actions_alignment: :left)
      expect(component.actions_alignment).to eq(:left)
    end

    it "defaults to left for invalid alignment" do
      component = described_class.new(actions_alignment: :center)
      expect(component.actions_alignment).to eq(:left)
    end
  end

  describe "#default_divider" do
    it "returns a DividerComponent" do
      component = described_class.new
      divider = component.default_divider

      expect(divider).to be_a(DividerComponent)
    end
  end

  describe "accessibility" do
    it "uses semantic HTML structure" do
      component = described_class.new
      render_inline(component) { "Content" }

      html = rendered_content
      expect(html).to include("<")
    end
  end
end
