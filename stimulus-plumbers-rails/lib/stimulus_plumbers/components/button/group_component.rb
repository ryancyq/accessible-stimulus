# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Button
      class GroupComponent < StimulusPlumbers::Components::Plumber::Base
        renders_one :primary_button, ButtonComponent
        renders_many :secondary_buttons, ButtonComponent

        attr_reader :alignment, :direction

        def initialize(alignment: :right, direction: :row, **kwargs)
          @alignment = alignment.to_sym
          @direction = direction.to_sym
          super(alignment: @alignment, direction: @direction, **kwargs)
        end
      end
    end
  end
end
