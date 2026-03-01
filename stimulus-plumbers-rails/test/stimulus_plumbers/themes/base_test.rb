# frozen_string_literal: true

require "test_helper"

class BaseThemeTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::Base.new
  end

  # #resolve
  def test_resolve_returns_empty_hash_for_an_unknown_component
    assert_equal({}, @theme.resolve(:nonexistent))
  end

  def test_resolve_raises_not_implemented_error_for_all_known_components
    %i[button button_group card card_section avatar action_list
       action_list_item divider popover calendar_day].each do |component|
      assert_raises(NotImplementedError) { @theme.resolve(component) }
    end
  end

  # with invalid args — uses a concrete subclass that returns empty hashes
  def build_stub_theme
    Class.new(StimulusPlumbers::Themes::Base) do
      private

      StimulusPlumbers::Themes::Base::ARG_SCHEMA.each_key do |component|
        define_method(:"#{component}_classes") { |**| {} }
      end
    end.new
  end

  def test_coerces_invalid_variant_to_default_and_warns
    stub_theme   = build_stub_theme
    mock_logger  = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value :invalid}])
    Rails.stub(:logger, mock_logger) do
      stub_theme.resolve(:button, variant: :invalid)
    end
    mock_logger.verify
  end

  def test_coerces_invalid_size_to_default_and_warns
    stub_theme  = build_stub_theme
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value :xl}])
    Rails.stub(:logger, mock_logger) do
      stub_theme.resolve(:button, size: :xl)
    end
    mock_logger.verify
  end

  def test_coerces_invalid_alignment_to_default_and_warns
    stub_theme  = build_stub_theme
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value :diagonal}])
    Rails.stub(:logger, mock_logger) do
      stub_theme.resolve(:button_group, alignment: :diagonal)
    end
    mock_logger.verify
  end

  def test_coerces_invalid_active_value_to_false_and_warns
    stub_theme  = build_stub_theme
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value "yes"}])
    Rails.stub(:logger, mock_logger) do
      stub_theme.resolve(:action_list_item, active: "yes")
    end
    mock_logger.verify
  end
end
