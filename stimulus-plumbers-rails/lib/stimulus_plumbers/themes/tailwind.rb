# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    class Tailwind < Base
      BUTTON_VARIANT_KLASSES = {
        primary:     %w[
          bg-[--sp-color-primary]
          text-[--sp-color-primary-fg]
          hover:bg-[--sp-color-primary]/90
          focus-visible:ring-[--sp-focus-ring-color]
        ].freeze,
        secondary:   %w[
          bg-[--sp-color-muted]
          text-[--sp-color-fg]
          hover:bg-[--sp-color-border]
        ].freeze,
        outline:     %w[
          border border-[--sp-color-border]
          bg-transparent
          text-[--sp-color-fg]
          hover:bg-[--sp-color-muted]
        ].freeze,
        destructive: %w[
          bg-[--sp-color-destructive]
          text-[--sp-color-destructive-fg]
          hover:bg-[--sp-color-destructive]/90
        ].freeze,
        ghost:       %w[hover:bg-[--sp-color-muted] text-[--sp-color-fg]].freeze,
        link:        %w[text-[--sp-color-primary] underline-offset-4 hover:underline].freeze
      }.freeze

      BUTTON_SIZE_KLASSES = {
        sm: %w[h-8 px-[--sp-space-3] text-[--sp-text-sm]].freeze,
        md: %w[h-9 px-[--sp-space-4] text-[--sp-text-base]].freeze,
        lg: %w[h-11 px-[--sp-space-6] text-[--sp-text-lg]].freeze
      }.freeze

      FLEX_ALIGNMENT_KLASSES = {
        row: {
          left:   "justify-start",
          center: %w[justify-center items-center].freeze,
          right:  "justify-end",
          top:    "items-start",
          bottom: "items-end"
        }.freeze,
        col: {
          top:    "justify-start",
          center: %w[justify-center items-center].freeze,
          bottom: "justify-end",
          left:   "items-start",
          right:  "items-end"
        }.freeze
      }.freeze

      AVATAR_SIZE_KLASSES = {
        sm: "size-[--sp-icon-size]",
        md: "size-[--sp-avatar-size]",
        lg: "size-12"
      }.freeze

      ACTION_LIST_ACTIVE_KLASSES = %w[bg-[--sp-color-primary]/10 text-[--sp-color-primary]].freeze

      CALENDAR_DAY_SELECTED_KLASSES = %w[
        bg-[--sp-color-primary]
        text-[--sp-color-primary-fg]
        hover:bg-[--sp-color-primary]/90
      ].freeze

      private

      def button_classes(variant: :primary, size: :md)
        {
          classes: klasses(
            "inline-flex",
            "items-center",
            "justify-center",
            "gap-2",
            "font-medium",
            "rounded-[--sp-radius-md]",
            "transition-colors",
            "focus-visible:outline-none",
            "focus-visible:ring-2",
            "focus-visible:ring-offset-2",
            "disabled:pointer-events-none",
            "disabled:opacity-50",
            *BUTTON_VARIANT_KLASSES.fetch(variant, []),
            *BUTTON_SIZE_KLASSES.fetch(size, [])
          )
        }
      end

      def button_group_classes(alignment: :left, direction: :row)
        {
          classes: klasses(
            "flex",
            "gap-[--sp-space-2]",
            *Array(FLEX_ALIGNMENT_KLASSES.dig(direction, alignment))
          )
        }
      end

      def card_classes
        {
          classes: klasses(
            "rounded-[--sp-radius-lg]",
            "border",
            "border-[--sp-color-border]",
            "bg-[--sp-color-bg]",
            "shadow-[--sp-shadow-sm]"
          )
        }
      end

      def card_section_classes
        { classes: klasses("p-[--sp-space-6]") }
      end

      def avatar_classes(size: :md)
        {
          classes: klasses(
            AVATAR_SIZE_KLASSES.fetch(size, AVATAR_SIZE_KLASSES[:md]),
            "rounded-[--sp-radius-full]",
            "overflow-hidden",
            "inline-flex",
            "items-center",
            "justify-center",
            "bg-[--sp-color-muted]",
            "text-[--sp-color-muted-fg]"
          )
        }
      end

      def action_list_classes
        { classes: klasses("py-[--sp-space-1]") }
      end

      def action_list_item_classes(active: false)
        {
          classes: klasses(
            "flex",
            "items-center",
            "gap-[--sp-space-2]",
            "w-full",
            "px-[--sp-space-2]",
            "py-[--sp-space-1]",
            "rounded-[--sp-radius-sm]",
            "text-[--sp-text-sm]",
            "cursor-pointer",
            "select-none",
            "outline-none",
            "hover:bg-[--sp-color-muted]",
            "focus:bg-[--sp-color-muted]",
            "focus:text-[--sp-color-fg]",
            *(active ? ACTION_LIST_ACTIVE_KLASSES : [])
          )
        }
      end

      def divider_classes
        {
          classes: klasses(
            "border-t",
            "border-[--sp-color-border]",
            "my-[--sp-space-1]"
          )
        }
      end

      def popover_classes
        {
          classes: klasses(
            "rounded-[--sp-radius-lg]",
            "border",
            "border-[--sp-color-border]",
            "bg-[--sp-color-bg]",
            "shadow-[--sp-shadow-md]",
            "z-[--sp-z-popover]"
          )
        }
      end

      def calendar_day_classes(today: false, selected: false, outside: false)
        {
          classes: klasses(
            "size-[--sp-calendar-day-size]",
            "rounded-[--sp-radius-md]",
            "flex",
            "items-center",
            "justify-center",
            "text-[--sp-text-sm]",
            "hover:bg-[--sp-color-muted]",
            "cursor-pointer",
            *(today    ? ["font-bold"] : []),
            *(selected ? CALENDAR_DAY_SELECTED_KLASSES : []),
            *(outside  ? %w[text-[--sp-color-muted-fg] opacity-50] : [])
          )
        }
      end

      def klasses(*classes)
        classes.flatten.reject(&:blank?).join(" ")
      end
    end
  end
end
