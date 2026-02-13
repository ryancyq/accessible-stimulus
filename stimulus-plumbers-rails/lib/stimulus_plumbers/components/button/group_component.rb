# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Button
      class GroupComponent < StimulusPlumbers::Components::Plumber::Base
        renders_one :primary_button, ButtonComponent
        renders_many :secondary_buttons, ButtonComponent

        attr_reader :alignment

        def initialize(alignment: :right, **kwargs)
          super(**kwargs)
          @alignment = alignment.to_sym == :right ? :right : :left
        end
      end
    end
  end
end
