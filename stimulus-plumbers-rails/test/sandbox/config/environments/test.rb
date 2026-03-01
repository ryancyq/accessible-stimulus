# frozen_string_literal: true

# Test environment configuration
Rails.application.configure do
  config.eager_load = false
  config.cache_classes = true
  config.logger = Logger.new(nil)
end
