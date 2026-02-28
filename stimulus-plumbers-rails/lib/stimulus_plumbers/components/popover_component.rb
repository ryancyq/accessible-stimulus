# frozen_string_literal: true

class PopoverComponent < StimulusPlumbers::Components::Plumber::Base
  renders_one :activator
  renders_one :button

  attr_reader :interactive, :scrollable

  def initialize(interactive: true, scrollable: false, **kwargs)
    @interactive = interactive
    @scrollable = scrollable
    super(**kwargs)
  end
end
