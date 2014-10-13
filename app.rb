require 'rubygems'
require 'bundler'
require 'active_support'
require 'kubr'

# Setup load paths
Bundler.require
$: << File.expand_path('../', __FILE__)

Kubr.configure do |config|
  config.url = "#{ENV['KUBERNETES_API_ENDPOINT']}/api/v1beta1"
end

# Require base
require 'sinatra/base'

require 'app/models'
require 'app/routes'
require 'app/utils'

module KubernetesAdapter
  class App < Sinatra::Application
    configure do
      disable :method_override
      disable :static
    end

    use KubernetesAdapter::Routes::Services
  end
end

include KubernetesAdapter::Models
