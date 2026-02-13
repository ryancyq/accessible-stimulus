# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module DatePicker
      class MonthComponent < StimulusPlumbers::Components::Plumber::Base
        def stimulus_controller
          "calendar-month"
        end
      end
    end
  end
end
