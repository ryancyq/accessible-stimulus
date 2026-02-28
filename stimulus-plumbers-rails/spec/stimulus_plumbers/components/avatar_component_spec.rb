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

  describe "#color_class" do
    it "returns first color in the range when no name or initials" do
      component = described_class.new

      expect(component.color_class).to eq(component.theme.avatar_color_range.first)
    end

    it "consistently returns same color for same name" do
      component = described_class.new(name: "John Doe")

      expect(component.color_class).to eq(component.color_class)
    end

    it "returns a color from the theme color range for a given name" do
      component = described_class.new(name: "Test")

      expect(component.theme.avatar_color_range).to include(component.color_class)
    end

    it "returns a color from the theme color range based on initials when name is nil" do
      component = described_class.new(initials: "AB")

      expect(component.theme.avatar_color_range).to include(component.color_class)
    end

    it "returns the resolved css class for an explicit color key" do
      component = described_class.new(name: "John", color: :indigo)

      expect(component.color_class).to eq(component.theme.avatar_colors.fetch(:indigo))
    end

    it "uses explicit color over computed color from name" do
      auto_component    = described_class.new(name: "John")
      colored_component = described_class.new(name: "John", color: :rose)

      expect(colored_component.color_class).not_to eq(auto_component.color_class)
      expect(colored_component.color_class).to eq(colored_component.theme.avatar_colors.fetch(:rose))
    end
  end
end
