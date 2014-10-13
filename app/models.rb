module KubernetesAdapter
  module Models
    autoload :Converter, 'app/models/converter'
    autoload :KService, 'app/models/k_service'
    autoload :KubernetesModel, 'app/models/kubernetes_model'
    autoload :Pod, 'app/models/pod'
    autoload :ReplicationController, 'app/models/replication_controller'
    autoload :Service, 'app/models/service'
  end
end
