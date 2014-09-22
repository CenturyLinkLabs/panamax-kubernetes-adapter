require 'rubygems'
require 'bundler'
require 'active_support'

# Setup load paths
Bundler.require
$: << File.expand_path('../', __FILE__)

# Require base
require 'sinatra/base'

require 'app/routes/services'

Kubr.configure do |config|
  config.url = "#{ENV['KUBERNETES_API_ENDPOINT']}/api/v1beta1"
end

module KubernetesAdapter
  class App < Sinatra::Application
    configure do
      disable :method_override
      disable :static
    end

    use Services
  end
end
