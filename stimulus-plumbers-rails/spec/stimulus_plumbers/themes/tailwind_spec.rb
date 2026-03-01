# frozen_string_literal: true

require "rails_helper"

RSpec.describe StimulusPlumbers::Themes::Tailwind do
  subject(:theme) { described_class.new }

  def classes_for(component, **args)
    theme.resolve(component, **args)[:classes]
  end

  describe "#resolve :button" do
    it "returns a classes string" do
      expect(classes_for(:button)).to be_a(String).and be_present
    end

    it "includes base layout classes" do
      expect(classes_for(:button)).to include("inline-flex", "items-center", "font-medium")
    end

    it "includes primary variant classes by default" do
      expect(classes_for(:button)).to include("bg-[--sp-color-primary]", "text-[--sp-color-primary-fg]")
    end

    it "includes medium size classes by default" do
      expect(classes_for(:button)).to include("h-9")
    end

    StimulusPlumbers::Themes::Base::ARG_SCHEMA[:button][:variant][:range].each do |variant|
      it "resolves :#{variant} variant without error" do
        expect { classes_for(:button, variant: variant) }.not_to raise_error
      end
    end

    StimulusPlumbers::Themes::Base::SIZE_RANGE.each do |size|
      it "resolves :#{size} size" do
        height = { sm: "h-8", md: "h-9", lg: "h-11" }
        expect(classes_for(:button, size: size)).to include(height[size])
      end
    end

    it "falls back to :primary for unknown variant" do
      expect(classes_for(:button, variant: :unknown)).to include("bg-[--sp-color-primary]")
    end
  end

  describe "#resolve :button_group" do
    it "returns a classes string" do
      expect(classes_for(:button_group)).to be_a(String).and be_present
    end

    it "includes flex base classes" do
      expect(classes_for(:button_group)).to include("flex", "gap-[--sp-space-2]")
    end

    it "includes alignment class for :left" do
      expect(classes_for(:button_group, alignment: :left)).to include("justify-start")
    end

    it "includes alignment class for :right" do
      expect(classes_for(:button_group, alignment: :right)).to include("justify-end")
    end

    it "includes alignment classes for :center" do
      result = classes_for(:button_group, alignment: :center)
      expect(result).to include("justify-center", "items-center")
    end
  end

  describe "#resolve :card" do
    it "returns a classes string" do
      expect(classes_for(:card)).to be_a(String).and be_present
    end

    it "includes border and background classes" do
      expect(classes_for(:card)).to include("border", "bg-[--sp-color-bg]", "rounded-[--sp-radius-lg]")
    end
  end

  describe "#resolve :card_section" do
    it "returns a classes string with padding" do
      expect(classes_for(:card_section)).to include("p-[--sp-space-6]")
    end
  end

  describe "#resolve :avatar" do
    it "returns a classes string" do
      expect(classes_for(:avatar)).to be_a(String).and be_present
    end

    it "includes layout and shape classes" do
      expect(classes_for(:avatar)).to include("inline-flex", "rounded-[--sp-radius-full]")
    end

    StimulusPlumbers::Themes::Base::SIZE_RANGE.each do |size|
      it "resolves :#{size} size" do
        size_class = StimulusPlumbers::Themes::Tailwind::AVATAR_SIZE_KLASSES[size]
        expect(classes_for(:avatar, size: size)).to include(size_class)
      end
    end

    describe "color" do
      it "exposes AVATAR_COLORS as a hash of symbol keys to css class strings" do
        expect(StimulusPlumbers::Themes::Tailwind::AVATAR_COLORS).to be_a(Hash).and be_present
        expect(StimulusPlumbers::Themes::Tailwind::AVATAR_COLORS.keys).to all(be_a(Symbol))
        expect(StimulusPlumbers::Themes::Tailwind::AVATAR_COLORS.values).to all(be_a(String))
      end

      it "avatar_color_range returns the css class values of AVATAR_COLORS" do
        expect(theme.avatar_color_range).to eq(StimulusPlumbers::Themes::Tailwind::AVATAR_COLORS.values)
      end

      it "avatar_colors returns AVATAR_COLORS" do
        expect(theme.avatar_colors).to eq(StimulusPlumbers::Themes::Tailwind::AVATAR_COLORS)
      end

      it "resolves each color key to a css class string" do
        StimulusPlumbers::Themes::Tailwind::AVATAR_COLORS.each do |key, css_class|
          expect(theme.avatar_colors.fetch(key)).to eq(css_class)
        end
      end
    end
  end

  describe "#resolve :action_list" do
    it "returns a classes string with padding" do
      expect(classes_for(:action_list)).to include("py-[--sp-space-1]")
    end
  end

  describe "#resolve :action_list_item" do
    it "returns a classes string" do
      expect(classes_for(:action_list_item)).to be_a(String).and be_present
    end

    it "includes base item classes" do
      expect(classes_for(:action_list_item)).to include("flex", "cursor-pointer", "rounded-[--sp-radius-sm]")
    end

    it "excludes active classes when inactive" do
      expect(classes_for(:action_list_item, active: false))
        .not_to include("bg-[--sp-color-primary]/10")
    end

    it "includes active classes when active" do
      expect(classes_for(:action_list_item, active: true))
        .to include("bg-[--sp-color-primary]/10", "text-[--sp-color-primary]")
    end
  end

  describe "#resolve :divider" do
    it "returns a classes string with border" do
      expect(classes_for(:divider)).to include("border-t", "border-[--sp-color-border]")
    end
  end

  describe "#resolve :popover" do
    it "returns a classes string" do
      expect(classes_for(:popover)).to be_a(String).and be_present
    end

    it "includes border, background and z-index classes" do
      expect(classes_for(:popover)).to include("border", "bg-[--sp-color-bg]", "z-[--sp-z-popover]")
    end
  end

  describe "#resolve :calendar_day" do
    it "returns a classes string" do
      expect(classes_for(:calendar_day)).to be_a(String).and be_present
    end

    it "includes base day classes" do
      expect(classes_for(:calendar_day)).to include("flex", "cursor-pointer")
    end

    it "includes font-bold when today" do
      expect(classes_for(:calendar_day, today: true)).to include("font-bold")
    end

    it "excludes font-bold when not today" do
      expect(classes_for(:calendar_day, today: false)).not_to include("font-bold")
    end

    it "includes selected classes when selected" do
      expect(classes_for(:calendar_day, selected: true))
        .to include("bg-[--sp-color-primary]", "text-[--sp-color-primary-fg]")
    end

    it "includes outside classes when outside month" do
      expect(classes_for(:calendar_day, outside: true))
        .to include("text-[--sp-color-muted-fg]", "opacity-50")
    end
  end
end
