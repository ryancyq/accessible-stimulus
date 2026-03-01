# frozen_string_literal: true

class CardComponent < StimulusPlumbers::Components::Plumber::Base
  include ViewComponent::SlotableDefault

  renders_one :header
  renders_one :divider, DividerComponent
  renders_many :sections, StimulusPlumbers::Components::Card::SectionComponent
  renders_one :primary_action
  renders_many :secondary_actions

  attr_reader :title, :divided, :actions_alignment
  alias_method :divided?, :divided

  def initialize(title: nil, divided: false, actions_alignment: :right, **kwargs)
    @title = title
    @divided = divided
    @actions_alignment = actions_alignment.to_sym == :right ? :right : :left
    super(**kwargs)
  end

  def default_divider
    DividerComponent.new
  end
end
