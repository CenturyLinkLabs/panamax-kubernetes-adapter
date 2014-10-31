module KubernetesAdapter
  module Routes
    autoload :Base, 'app/routes/base'
    autoload :Healthcheck, 'app/routes/healthcheck'
    autoload :Metadata, 'app/routes/metadata'
    autoload :Services, 'app/routes/services'
  end
end
