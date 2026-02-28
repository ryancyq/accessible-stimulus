# frozen_string_literal: true

require "rails_helper"

RSpec.describe StimulusPlumbers::Themes::Base do
  subject(:theme) { described_class.new }

  describe "#resolve" do
    it "returns {} for an unknown component" do
      expect(theme.resolve(:nonexistent)).to eq({})
    end

    it "raises NotImplementedError for all known components since Base has no styling" do
      %i[button button_group card card_section avatar action_list
         action_list_item divider popover calendar_day].each do |component|
        expect { theme.resolve(component) }.to raise_error(NotImplementedError)
      end
    end

    context "with invalid args" do
      subject(:theme) do
        Class.new(described_class) do
          private

          StimulusPlumbers::Themes::Base::ARG_SCHEMA.each_key do |component|
            define_method(:"#{component}_classes") { |**| {} }
          end
        end.new
      end

      before { allow(Rails.logger).to receive(:warn) }

      it "coerces an invalid variant to the default and warns" do
        theme.resolve(:button, variant: :invalid)
        expect(Rails.logger).to have_received(:warn).with(%r{unknown value :invalid})
      end

      it "coerces an invalid size to the default and warns" do
        theme.resolve(:button, size: :xl)
        expect(Rails.logger).to have_received(:warn).with(%r{unknown value :xl})
      end

      it "coerces an invalid alignment to the default and warns" do
        theme.resolve(:button_group, alignment: :diagonal)
        expect(Rails.logger).to have_received(:warn).with(%r{unknown value :diagonal})
      end

      it "coerces an invalid active value to false and warns" do
        theme.resolve(:action_list_item, active: "yes")
        expect(Rails.logger).to have_received(:warn).with(%r{unknown value "yes"})
      end
    end
  end
end
