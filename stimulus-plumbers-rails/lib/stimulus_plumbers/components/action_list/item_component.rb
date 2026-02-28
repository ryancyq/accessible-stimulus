# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module ActionList
      class ItemComponent < ButtonComponent
        def initialize(active: false, **kwargs)
          @active = active
          super
        end
      end
    end
  end
end
