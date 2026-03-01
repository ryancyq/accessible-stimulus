# frozen_string_literal: true

# Set up Bundler
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../../../Gemfile", __dir__)
require "bundler/setup" if File.exist?(ENV["BUNDLE_GEMFILE"])

# Set up load path
$LOAD_PATH.unshift File.expand_path("../../../../lib", __dir__)
