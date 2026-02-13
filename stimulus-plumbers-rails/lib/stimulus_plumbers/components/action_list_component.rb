# frozen_string_literal: true

class ActionListComponent < StimulusPlumbers::Components::Plumber::Base
  include ViewComponent::SlotableDefault

  renders_one :divider, DividerComponent
  renders_many :items
  renders_many :sections, StimulusPlumbers::Components::ActionList::SectionComponent

  def default_divider
    DividerComponent.new
  end
end
