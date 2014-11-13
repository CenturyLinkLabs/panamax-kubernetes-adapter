require 'rubygems'
require 'bundler'
require 'active_support'
require 'kubr'

# Setup load paths
Bundler.require
$: << File.expand_path('../', __FILE__)

Kubr.configure do |config|
  config.url = "#{ENV['KUBERNETES_MASTER']}/api/v1beta1"
  config.username = ENV['KUBERNETES_USERNAME']
  config.password = ENV['KUBERNETES_PASSWORD']
end

# Require base
require 'sinatra/base'

require 'app/models'
require 'app/routes'
require 'app/utils'

module KubernetesAdapter

  IMPL_VERSION = ENV['ADAPTER_VERSION']
  API_VERSION = 'v1'
  TYPE = 'kubernetes'

  class App < Sinatra::Application
    configure do
      disable :method_override
      disable :static
    end

    use KubernetesAdapter::Routes::Healthcheck
    use KubernetesAdapter::Routes::Metadata
    use KubernetesAdapter::Routes::Services
  end
end

include KubernetesAdapter::Models
