module KubernetesAdapter
  module Models
    class Converter

      attr_accessor :services

      def initialize(services)
        self.services = services
      end

      def pods
        services.each_with_object([]) do |service, ary|
          ary << pod_from_service(service) if service.scale == 1
        end
      end

      def replication_controllers
        services.each_with_object([]) do |service, ary|
          ary << replication_controller_from_service(service) if service.scale > 1
        end
      end

      def k_services
        k_services_from_links + k_services_from_clusters
      end

      private

      def k_services_from_links
        services.each_with_object([]) do |service, ary|
          service.links.each do |link|
            linked_to_service = find_service(link[:name])
            ary << k_service_from_link(linked_to_service, link[:alias])
          end
        end
      end

      def k_service_from_link(linked_to_service, service_alias)
        k_service_from_service(linked_to_service).tap do |k_service|
          k_service.id = service_alias.downcase.gsub(/_/, '-')
        end
      end

      def k_services_from_clusters
        services.each_with_object([]) do |service, ary|
          ary << k_service_from_service(service) if service.scale > 1
        end
      end

      def k_service_from_service(service)
        KService.new(name: service.name).tap do |k_service|
          if service.ports.any?
            port = service.ports.first
            k_service.port = port[:hostPort]
            k_service.container_port =  port[:containerPort]
          end
        end
      end

      def replication_controller_from_service(service)
        ReplicationController.new(
          name: service.name,
          replicas: service.scale,
          image: service.source,
          command: service.command,
          ports: service.ports,
          environment: service.environment)
      end

      def pod_from_service(service)
        Pod.new(
          name: service.name,
          image: service.source,
          command: service.command,
          ports: service.ports,
          environment: service.environment)
      end

      def find_service(name)
        services.find { |service| service.name == name }
      end
    end
  end
end
