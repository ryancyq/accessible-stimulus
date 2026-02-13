# frozen_string_literal: true

class AvatarComponent < StimulusPlumbers::Components::Plumber::Base
  attr_reader :name, :initials, :url

  def initialize(name: nil, initials: nil, url: nil, **kwargs)
    unless name.nil?
      kwargs[:aria] ||= {}
      kwargs[:aria][:label] = name
    end

    super(**kwargs)
    @name = name
    @initials = initials
    @url = url
  end

  def color_attrs(colors)
    return colors.first unless name || initials

    i = (name || initials).bytes.reduce(0) { |hash, byte| hash ^ byte }
    colors[i % colors.length]
  end
end
