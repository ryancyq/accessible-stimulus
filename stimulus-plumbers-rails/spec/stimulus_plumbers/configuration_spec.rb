# frozen_string_literal: true

require "rails_helper"

RSpec.describe StimulusPlumbers::Configuration do
  subject(:config) { described_class.new }

  describe "#theme" do
    it "defaults to a Tailwind instance" do
      expect(config.theme).to be_a(StimulusPlumbers::Themes::Tailwind)
    end

    it "is memoized" do
      expect(config.theme).to be(config.theme)
    end
  end

  describe "#theme=" do
    it "accepts :tailwind" do
      config.theme = :tailwind
      expect(config.theme).to be_a(StimulusPlumbers::Themes::Tailwind)
    end

    it "accepts a Themes::Base instance directly" do
      custom = StimulusPlumbers::Themes::Base.new
      config.theme = custom
      expect(config.theme).to be(custom)
    end

    it "raises ArgumentError for an unknown symbol" do
      expect { config.theme = :unknown }
        .to raise_error(ArgumentError, /Unknown theme/)
    end
  end

  describe "#log_formatter" do
    it "defaults to the built-in prefix formatter" do
      expect(config.log_formatter.call("hello")).to eq("[StimulusPlumbers] hello")
    end

    it "is memoized" do
      expect(config.log_formatter).to be(config.log_formatter)
    end
  end

  describe "#log_formatter=" do
    it "accepts any callable" do
      config.log_formatter = ->(msg) { "PREFIX: #{msg}" }
      expect(config.log_formatter.call("test")).to eq("PREFIX: test")
    end

    it "accepts a proc" do
      config.log_formatter = proc { |msg| msg.upcase }
      expect(config.log_formatter.call("test")).to eq("TEST")
    end

    it "raises ArgumentError when given a non-callable" do
      expect { config.log_formatter = "a string" }
        .to raise_error(ArgumentError, /respond to #call/)
    end

    it "raises ArgumentError when given nil" do
      expect { config.log_formatter = nil }
        .to raise_error(ArgumentError, /respond to #call/)
    end
  end
end
