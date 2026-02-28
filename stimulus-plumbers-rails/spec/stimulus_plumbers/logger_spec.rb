# frozen_string_literal: true

require "rails_helper"

RSpec.describe StimulusPlumbers::Logger do
  after do
    StimulusPlumbers.config.log_formatter = StimulusPlumbers::Configuration::DEFAULT_LOG_FORMATTER
  end

  describe "log levels" do
    StimulusPlumbers::Logger::LEVELS.each do |level|
      describe ".#{level}" do
        it "formats the message and delegates to Rails.logger" do
          allow(Rails.logger).to receive(level)
          described_class.public_send(level, "test message")
          expect(Rails.logger).to have_received(level).with("[StimulusPlumbers] test message")
        end
      end
    end
  end

  describe "custom log_formatter" do
    it "applies the configured formatter before delegating" do
      StimulusPlumbers.config.log_formatter = ->(msg) { "CUSTOM: #{msg}" }
      allow(Rails.logger).to receive(:warn)
      described_class.warn("hello")
      expect(Rails.logger).to have_received(:warn).with("CUSTOM: hello")
    end
  end
end
