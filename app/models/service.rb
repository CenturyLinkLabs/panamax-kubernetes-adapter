module KubernetesAdapter
  module Models
    class Service

      using KubernetesAdapter::StringExtensions

      attr_accessor :name, :source, :command, :ports, :expose, :environment,
        :volumes, :links, :deployment

      def self.create_all(attrs)
        attrs.map { |service_attrs| Service.new(service_attrs) }
      end

      def initialize(attrs={})
        self.name = attrs[:name]
        self.source = attrs[:source]
        self.command= attrs[:command]
        self.ports = attrs[:ports] || []
        self.expose = attrs[:expose] || []
        self.environment = attrs[:environment] || []
        self.volumes = attrs[:volumes] || []
        self.links = attrs[:links] || []
        self.deployment = attrs[:deployment] || {}
      end

      def name
        @name ? @name.sanitize : nil
      end

      def links
        @links.map do |link|
          link[:name] = link[:name].sanitize
          link
        end
      end

      def scale
        self.deployment.fetch(:count, 1).to_i
      end

      def min_port
        all_ports = []

        all_ports += self.expose.map do |exposed_port|
          { hostPort: exposed_port, containerPort: exposed_port }
        end

        all_ports += self.ports.map do |mapped_port|
          {
            hostPort: mapped_port[:hostPort] || mapped_port[:containerPort],
            containerPort: mapped_port[:containerPort]
          }
        end

        all_ports.sort_by { |port| port[:containerPort] }.first
      end
    end
  end
end
