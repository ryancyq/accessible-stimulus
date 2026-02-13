# frozen_string_literal: true

require "rails_helper"

RSpec.describe PopoverComponent, type: :component do
  describe "rendering" do
    it "renders basic popover in template when interactive" do
      component = described_class.new(interactive: true)
      render_inline(component) { "Popover content" }

      # Content is in a template tag when interactive (check HTML source)
      html = rendered_content
      expect(html).to include("<template>")
    end

    it "renders popover content directly when not interactive" do
      component = described_class.new(interactive: false)
      render_inline(component) { "Popover content" }

      expect(page).to have_text("Popover content")
      expect(page).not_to have_css("template")
    end

    it "renders with custom attributes" do
      component = described_class.new(id: "user-menu", class: "dropdown")
      render_inline(component)

      expect(page).to have_css("#user-menu.dropdown")
    end

    it "renders with activator slot" do
      component = described_class.new
      component.with_activator { "Click me" }
      render_inline(component)

      expect(page).to have_text("Click me")
    end

    it "renders with button slot" do
      component = described_class.new
      component.with_button { "Open" }
      render_inline(component)

      expect(page).to have_text("Open")
    end
  end

  describe "interactive mode" do
    it "defaults to interactive true" do
      component = described_class.new
      expect(component.interactive).to be true
    end

    it "can be set to non-interactive" do
      component = described_class.new(interactive: false)
      expect(component.interactive).to be false
    end

    it "accepts interactive true explicitly" do
      component = described_class.new(interactive: true)
      expect(component.interactive).to be true
    end
  end

  describe "scrollable mode" do
    it "defaults to scrollable false" do
      component = described_class.new
      expect(component.scrollable).to be false
    end

    it "can be set to scrollable" do
      component = described_class.new(scrollable: true)
      expect(component.scrollable).to be true
    end

    it "accepts scrollable false explicitly" do
      component = described_class.new(scrollable: false)
      expect(component.scrollable).to be false
    end
  end

  describe "accessibility" do
    it "renders with data attributes for Stimulus" do
      component = described_class.new(
        data: { controller: "popover", action: "click->popover#toggle" }
      )
      render_inline(component)

      expect(page).to have_css('[data-controller="popover"]')
      expect(page).to have_css('[data-action="click->popover#toggle"]')
    end

    it "supports ARIA attributes" do
      component = described_class.new(
        aria: { haspopup: "true", expanded: "false" }
      )
      render_inline(component)

      expect(page).to have_css('[aria-haspopup="true"]')
      expect(page).to have_css('[aria-expanded="false"]')
    end
  end

  describe "combined options" do
    it "handles both interactive and scrollable" do
      component = described_class.new(interactive: true, scrollable: true)

      expect(component.interactive).to be true
      expect(component.scrollable).to be true
    end

    it "handles non-interactive and scrollable" do
      component = described_class.new(interactive: false, scrollable: true)

      expect(component.interactive).to be false
      expect(component.scrollable).to be true
    end
  end
end
