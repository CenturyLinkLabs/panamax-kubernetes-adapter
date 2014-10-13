module KubernetesAdapter
  module Models
    class ReplicationController < Pod

      attr_accessor :replicas

      def self.find(id)
        new(id: id).tap(&:refresh)
      end

      def initialize(attrs={})
        super
        self.replicas = attrs[:replicas]
      end

      def id
        @id || (name ? "#{name}-replication-controller" : nil)
      end

      def start
        kubr.create_replication_controller(to_hash)
      end

      def destroy
        kubr.delete_replication_controller(id)
      end

      def refresh
        # If it exists, it's running
        kubr.get_replication_controller(id)
        @status = 'started'
      end

      private

      def to_hash
        {
          id: id,
          apiVersion: 'v1beta1',
          kind: 'ReplicationController',
          desiredState: {
            replicas: replicas,
            replicaSelector: {
              name: name
            },
            podTemplate: {
              desiredState: {
                manifest: manifest
              },
              labels: {
                name: name
              }
            }
          },
          labels: {
            name: name
          }
        }
      end

    end
  end
end
