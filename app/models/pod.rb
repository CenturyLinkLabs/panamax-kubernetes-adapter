module KubernetesAdapter
  module Models
    class Pod < KubernetesModel

      attr_accessor :name, :image, :command, :ports, :environment

      def self.find(id)
        new(id: id).tap(&:refresh)
      end

      def initialize(attrs={})
        self.name = attrs[:name]
        self.id = attrs[:id]
        self.image = attrs[:image]
        self.command= attrs[:command]
        self.ports = attrs[:ports] || []
        self.environment = attrs[:environment] || []
      end

      def id
        @id || (name ? "#{name}-pod" : nil)
      end

      def start
        kubr.create_pod(to_hash)
      end

      def destroy
        kubr.delete_pod(id)
      end

      def refresh
        pod = kubr.get_pod(id)
        @status = pod[:currentState][:status]
      end

      protected

      def to_hash
        {
          id: id,
          kind: 'Pod',
          apiVersion: 'v1beta1',
          desiredState: {
            manifest: manifest
          },
          labels: {
            name: name
          }
        }
      end

      def manifest
        {
          id: id,
          version: 'v1beta1',
          containers: [
            {
              name: name,
              image: image,
            }
          ]
        }.tap do |manifest|
          manifest[:containers].first.tap do |container|
            container[:command] = command if command
            container[:ports] = port_mapping if ports.any?
            container[:env] = environment_mapping if environment.any?
          end
        end
      end

      def port_mapping
        ports.map do |port|
          {
            hostPort: port[:hostPort] || port[:containerPort],
            containerPort: port[:containerPort],
            protocol: port[:protocol].try(:upcase) || 'TCP'
          }
        end
      end

      def environment_mapping
        environment.map do |env|
          {
            name: env[:variable],
            value: env[:value]
          }
        end
      end

    end
  end
end
