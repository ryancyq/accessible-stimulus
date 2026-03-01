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
    color_class_by_arg || color_class_by_name || theme.avatar_color_range.first
  end

  private

  def color_class_by_arg
    theme.avatar_colors.fetch(@color) if @color
  end

  def color_class_by_name
    seed = name || initials
    return unless seed

    theme.avatar_color_range[seed.bytes.reduce(:^) % theme.avatar_color_range.length]
  end
end
