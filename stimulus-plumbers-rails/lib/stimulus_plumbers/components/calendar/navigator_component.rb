# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Calendar
      class NavigatorComponent < StimulusPlumbers::Components::Plumber::Base
        attr_reader :direction

        def initialize(direction: nil, **kwargs)
          super(**kwargs)
          @direction = direction
        end
      end
    end
  end
end
