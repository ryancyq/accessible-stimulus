# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Card
      class SectionComponent < StimulusPlumbers::Components::Plumber::Base
        attr_reader :title

        def initialize(title: nil, **kwargs)
          @title = title
          super(**kwargs)
        end
      end
    end
  end
end
