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

    end
  end
end
