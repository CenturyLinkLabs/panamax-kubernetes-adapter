module KubernetesAdapter
  module Models
    class Service

      attr_accessor :name, :source, :command, :ports, :environment, :volumes,
        :links, :deployment

      def self.create_all(attrs)
        attrs.map { |service_attrs| Service.new(service_attrs) }
      end

      def initialize(attrs={})
        self.name = attrs[:name].try(:downcase)
        self.source = attrs[:source]
        self.command= attrs[:command]
        self.ports = attrs[:ports] || []
        self.environment = attrs[:environment] || []
        self.volumes = attrs[:volumes] || []
        self.links = attrs[:links] || []
        self.deployment = attrs[:deployment] || {}
      end

      def scale
        self.deployment.fetch(:count, 1)
      end
    end
  end
end
