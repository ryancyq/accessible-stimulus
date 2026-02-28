# frozen_string_literal: true

class AvatarComponent < StimulusPlumbers::Components::Plumber::Base
  attr_reader :name, :initials, :url

  def initialize(name: nil, initials: nil, url: nil, color: nil, **kwargs)
    @name = name
    @initials = initials
    @url = url
    @color = color
    kwargs[:aria] ||= {}
    kwargs[:aria][:label] = name unless name.nil?
    super(color: color, **kwargs)
  end

  def color_class
    klass = theme.avatar_colors.fetch(@color) if @color
    
    if !klass && (name || initials)
      i = (name || initials).bytes.reduce(0) { |hash, byte| hash ^ byte }
      klass = theme.avatar_color_range[i % theme.avatar_color_range.length]
    end

    return klass if klass

    theme.avatar_color_range.first
  end
end
