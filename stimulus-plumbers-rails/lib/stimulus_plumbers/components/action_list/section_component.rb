# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module ActionList
      class SectionComponent < StimulusPlumbers::Components::Plumber::Base
        renders_many :items, StimulusPlumbers::Components::ActionList::ItemComponent

        attr_reader :title

        def initialize(title: nil, **kwargs)
          super(**kwargs)
          @title = title
        end
      end
    end
  end
end
