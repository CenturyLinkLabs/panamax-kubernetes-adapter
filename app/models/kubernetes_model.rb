module KubernetesAdapter
  module Models
    class KubernetesModel

      attr_accessor :id
      attr_reader :status

      def self.create_all(services)
        [].tap do |ary|
          Converter.new(services).tap do |converter|
            ary.push(*converter.k_services)
            ary.push(*converter.replication_controllers)
            ary.push(*converter.pods)
          end
        end
      end

      def self.find(id)
        if id.end_with?('-pod')
          Pod.find(id)
        elsif id.end_with?('-replication-controller')
          ReplicationController.find(id)
        else
          KService.find(id)
        end
      end

      protected

      def kubr
        @kubr ||= Kubr::Client.new
      end

    end
  end
end
