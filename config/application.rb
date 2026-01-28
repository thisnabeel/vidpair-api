require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module VidroomApi
  class Application < Rails::Application
    config.load_defaults 8.1
    config.autoload_lib(ignore: %w[assets tasks])

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', 
          headers: :any, 
          methods: [:get, :put, :post, :patch, :options, :delete],
          expose: ['X-User-Email', 'X-User-Token']
      end
    end

    config.api_only = true
    config.action_cable.mount_path = '/cable'
  end
end

