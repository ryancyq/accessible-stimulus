# frozen_string_literal: true

class DividerComponent < StimulusPlumbers::Components::Plumber::Base
  def call
    render(ContainerComponent.new(**component_attrs, tag: :hr)) { content }
  end
end
