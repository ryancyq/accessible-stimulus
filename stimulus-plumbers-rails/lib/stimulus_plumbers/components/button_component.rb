# frozen_string_literal: true

class ButtonComponent < StimulusPlumbers::Components::Plumber::Base
  renders_one :prefix
  renders_one :suffix

  attr_reader :url, :external

  def initialize(url: nil, external: false, **kwargs)
    super(**kwargs)
    @url = url
    @external = external
  end
end
