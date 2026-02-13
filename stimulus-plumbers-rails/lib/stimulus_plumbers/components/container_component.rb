# frozen_string_literal: true

class ContainerComponent < ViewComponent::Base
  include StimulusPlumbers::Components::Plumber::Attributes

  attr_reader :tag

  def initialize(tag:, **kwargs)
    super()
    @tag = tag
    component_attrs(**kwargs)
  end

  def call
    content_tag(tag, content, component_attrs)
  end
end
