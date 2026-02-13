# frozen_string_literal: true

require "rails/engine"
require "view_component"

module StimulusPlumbers
  class Engine < ::Rails::Engine
    isolate_namespace StimulusPlumbers

    config.autoload_paths << File.expand_path("../stimulus-plumbers", __dir__)

    initializer "stimulus_plumbers.view_component" do
      ActiveSupport.on_load(:view_component) do
        # Ensure ViewComponent can find our components
      end
    end
  end
end
