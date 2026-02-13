# frozen_string_literal: true

require "rails_helper"

RSpec.describe AvatarComponent, type: :component do
  describe "rendering" do
    it "renders with name only" do
      component = described_class.new(name: "John Doe")
      render_inline(component)

      expect(page).to have_css('[aria-label="John Doe"]')
    end

    it "renders with initials" do
      component = described_class.new(name: "Jane Smith", initials: "JS")
      render_inline(component)

      expect(page).to have_text("JS")
    end

    it "renders with url" do
      component = described_class.new(name: "John", url: "/avatar.jpg")
      render_inline(component)

      expect(rendered_content).to include("/avatar.jpg")
    end

    it "renders with custom attributes" do
      component = described_class.new(
        name:  "Test User",
        id:    "user-avatar",
        class: "custom-avatar"
      )
      render_inline(component)

      expect(page).to have_css("#user-avatar.custom-avatar")
    end
  end

  describe "accessibility" do
    it "adds aria-label when name is provided" do
      component = described_class.new(name: "Alice Johnson")
      render_inline(component)

      expect(page).to have_css('[aria-label="Alice Johnson"]')
    end

    it "does not add aria-label when name is nil" do
      component = described_class.new(initials: "AJ")
      render_inline(component)

      expect(page).not_to have_css("[aria-label]")
    end
  end

  describe "#color_attrs" do
    it "returns first color when no name or initials" do
      component = described_class.new
      colors = %w[red blue green]

      expect(component.color_attrs(colors)).to eq("red")
    end

    it "consistently returns same color for same name" do
      component = described_class.new(name: "John Doe")
      colors = %w[red blue green yellow]

      color1 = component.color_attrs(colors)
      color2 = component.color_attrs(colors)

      expect(color1).to eq(color2)
    end

    it "returns color based on name hash" do
      component = described_class.new(name: "Test")
      colors = %w[red blue green]

      result = component.color_attrs(colors)

      expect(colors).to include(result)
    end

    it "returns color based on initials when name is nil" do
      component = described_class.new(initials: "AB")
      colors = %w[red blue green]

      result = component.color_attrs(colors)

      expect(colors).to include(result)
    end
  end
end
