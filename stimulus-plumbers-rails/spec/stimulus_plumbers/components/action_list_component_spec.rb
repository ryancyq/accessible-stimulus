# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActionListComponent, type: :component do
  let(:component) { described_class.new }

  describe "rendering" do
    it "renders list with items" do
      component.with_item { "First action" }
      component.with_item { "Second action" }
      component.with_item { "Third action" }

      render_inline(component)

      expect(page).to have_css("div > ul > li", count: 3)
      expect(page).to have_text("First action")
      expect(page).to have_text("Second action")
      expect(page).to have_text("Third action")
    end

    it "renders items as buttons when no url is provided" do
      component.with_item { "Click me" }
      render_inline(component)

      expect(page).to have_css("button", text: "Click me")
    end

    it "renders with custom attributes" do
      component = described_class.new(
        id:    "my-action-list",
        class: "custom-class",
        data:  { testid: "action-list" }
      )
      component.with_item { "Action" }
      render_inline(component)

      expect(page).to have_css("div#my-action-list.custom-class")
      expect(page).to have_css('[data-testid="action-list"]')
    end

    it "renders multiple sections with titles and dividers" do
      component.with_section(title: "Section 1") do |section|
        section.with_item { "Action 1.1" }
        section.with_item { "Action 1.2" }
      end
      component.with_section(title: "Section 2") do |section|
        section.with_item { "Action 2.1" }
        section.with_item { "Action 2.2" }
      end

      render_inline(component)

      expect(page).to have_css("li > div", count: 2)
      expect(page).to have_css("p", text: "Section 1")
      expect(page).to have_css("p", text: "Section 2")
      expect(page).to have_css("div > ul", count: 2)
      expect(page).to have_css("hr", count: 1)
      expect(page).to have_text("Action 1.1")
      expect(page).to have_text("Action 2.2")
    end

    it "renders sections without titles" do
      component.with_section { |s| s.with_item { "Action 1" } }
      component.with_section { |s| s.with_item { "Action 2" } }
      render_inline(component)

      expect(page).not_to have_css("p")
      expect(page).to have_css("li > div", count: 2)
    end

    it "does not render divider for single section" do
      component.with_section(title: "First") { |s| s.with_item { "Action 1" } }
      render_inline(component)

      expect(page).not_to have_css("hr")
    end

    it "renders mixed sections and items with divider" do
      component.with_section(title: "Section") { |s| s.with_item { "Section action" } }
      component.with_item { "Standalone action" }
      render_inline(component)

      expect(page).to have_css("hr", count: 1)
      expect(page).to have_text("Section action")
      expect(page).to have_text("Standalone action")
    end

    it "renders custom divider component" do
      component.with_divider(class: "custom-divider") { "---" }
      component.with_section(title: "First") { |s| s.with_item { "Action 1" } }
      component.with_section(title: "Second") { |s| s.with_item { "Action 2" } }
      render_inline(component)

      expect(page).to have_css("hr.custom-divider")
      expect(page).to have_text("---")
    end
  end

  describe "accessibility" do
    it "uses semantic list markup" do
      component.with_item { "Action 1" }
      component.with_item { "Action 2" }
      render_inline(component)

      expect(page).to have_css("ul > li", count: 2)
    end

    it "renders items as links when url is provided" do
      component.with_section do |section|
        section.with_item(url: "/path") { "Go somewhere" }
        section.with_item(url: "https://example.com", external: true) { "External link" }
      end
      render_inline(component)

      expect(page).to have_css("a[href='/path']", text: "Go somewhere")
      expect(page).to have_css('a[target="_blank"]', text: "External link")
    end

    it "uses semantic hr dividers" do
      component.with_section(title: "Section 1") { |s| s.with_item { "Action" } }
      component.with_section(title: "Section 2") { |s| s.with_item { "Action" } }
      render_inline(component)

      expect(page).to have_css("hr")
    end

    it "maintains keyboard focusability" do
      component.with_item { "Button action" }
      component.with_section { |s| s.with_item(url: "/home") { "Link action" } }
      render_inline(component)

      button = page.find("button")
      link = page.find("a")

      expect(button[:tabindex]).not_to eq("-1")
      expect(link[:href]).to be_present
    end

    it "maintains logical reading order" do
      component.with_section(title: "Navigation") do |section|
        section.with_item { "Home" }
        section.with_item { "About" }
      end
      component.with_section(title: "Account") do |section|
        section.with_item { "Profile" }
        section.with_item { "Settings" }
      end
      render_inline(component)

      html = rendered_content
      positions = %w[Navigation Home About Account Profile Settings].map { |text| html.index(text) }

      expect(positions).to eq(positions.sort)
    end

    it "preserves item order" do
      component.with_item { "First" }
      component.with_item { "Second" }
      component.with_item { "Third" }
      render_inline(component)

      html = rendered_content
      positions = %w[First Second Third].map { |text| html.index(text) }

      expect(positions).to eq(positions.sort)
    end

    it "supports data attributes for Stimulus controllers" do
      component = described_class.new(
        data: { controller: "action-list", action: "click->action-list#handleClick" }
      )
      component.with_item { "Action" }
      render_inline(component)

      expect(page).to have_css('[data-controller="action-list"]')
      expect(page).to have_css('[data-action="click->action-list#handleClick"]')
    end

    it "does not remove focus outlines" do
      component.with_item { "Focusable action" }
      render_inline(component)

      button = page.find("button")
      inline_style = button[:style].to_s

      expect(inline_style).not_to include("outline")
    end
  end
end
