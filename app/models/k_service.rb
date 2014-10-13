module KubernetesAdapter
  module Models
    class KService < KubernetesModel

      attr_accessor :name, :port, :container_port

      def self.find(id)
        new(id: id).tap(&:refresh)
      end

      def initialize(attrs={})
        self.id = attrs[:id]
        self.name = attrs[:name]
        self.port = attrs[:port]
        self.container_port = attrs[:container_port]
      end

      def id
        @id || (name ? name.downcase.gsub(/_/, '-') : nil)
      end

      def start
        kubr.create_service(to_hash)
      end

      def destroy
        kubr.delete_service(id)
      end

      def refresh
        # If it exists, it's running
        kubr.get_service(id)
        @status = 'started'
      end

      private

      def to_hash
        {
          id: id,
          apiVersion: 'v1beta1',
          kind: 'Service',
          port: port,
          labels: {
            name: name
          },
          selector: {
            name: name
          }
        }.tap do |service|
          service[:containerPort] = container_port if container_port
        end
      end

    end
  end
end
