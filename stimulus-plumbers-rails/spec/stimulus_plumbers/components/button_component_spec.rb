# frozen_string_literal: true

require "rails_helper"

RSpec.describe ButtonComponent, type: :component do
  describe "rendering" do
    it "renders basic button" do
      component = described_class.new
      render_inline(component) { "Click me" }

      expect(page).to have_text("Click me")
    end

    it "renders with custom attributes" do
      component = described_class.new(id: "submit-btn", class: "primary")
      render_inline(component) { "Submit" }

      expect(page).to have_css("#submit-btn.primary")
    end

    it "renders with prefix slot" do
      component = described_class.new
      component.with_prefix { "<span>→</span>".html_safe }
      render_inline(component) { "Next" }

      expect(page).to have_text("→")
      expect(page).to have_text("Next")
    end

    it "renders with suffix slot" do
      component = described_class.new
      component.with_suffix { "<span>✓</span>".html_safe }
      render_inline(component) { "Save" }

      expect(page).to have_text("Save")
      expect(page).to have_text("✓")
    end
  end

  describe "with url" do
    it "renders as link when url is provided" do
      component = described_class.new(url: "/dashboard")
      render_inline(component) { "Go to Dashboard" }

      expect(page).to have_css('a[href="/dashboard"]', text: "Go to Dashboard")
    end

    it "renders external link with target blank" do
      component = described_class.new(url: "https://example.com", external: true)
      render_inline(component) { "External" }

      expect(page).to have_css('a[href="https://example.com"][target="_blank"]')
    end

    it "does not add target blank for internal links" do
      component = described_class.new(url: "/internal", external: false)
      render_inline(component) { "Internal" }

      expect(page).to have_css('a[href="/internal"]')
      expect(page).not_to have_css('a[target="_blank"]')
    end
  end

  describe "accessibility" do
    it "is keyboard accessible" do
      component = described_class.new
      render_inline(component) { "Button" }

      # Button or link should be focusable (no negative tabindex)
      element = page.find_all("button, a").first
      expect(element[:tabindex]).not_to eq("-1")
    end

    it "renders semantic button by default" do
      component = described_class.new
      render_inline(component) { "Click" }

      expect(page).to have_css("button, a")
    end
  end
end
