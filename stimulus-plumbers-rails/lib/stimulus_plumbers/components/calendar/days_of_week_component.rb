# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Calendar
      class DaysOfWeekComponent < StimulusPlumbers::Components::Plumber::Base
        renders_many :days
      end
    end
  end
end
