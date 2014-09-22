module KubernetesAdapter
  class Service

    attr_accessor :id, :name, :source, :command, :ports, :environment, :volumes
    attr_reader :status

    def self.find(id)
      new('id' => id).tap(&:refresh)
    end

    def self.create(attrs)
      new(attrs).tap(&:load)
    end

    def initialize(attrs)
      self.name = attrs['name']
      self.id = attrs['id'] || attrs['name'].downcase
      self.source = attrs['source']
      self.command= attrs['command']
      self.ports = attrs['ports'] || []
      self.environment = attrs['environment'] || []
      self.volumes = attrs['volumes'] || []
    end

    def load
      kubr.create_pod(to_pod)
    end

    def start
      pod = kubr.get_pod(id)
      pod[:desiredState][:status] = 'Running'
      kubr.update_pod(id, pod)
    end

    def stop
      pod = kubr.get_pod(id)
      pod[:desiredState][:status] = 'Stopped'
      kubr.update_pod(id, pod)
    end

    def destroy
      kubr.delete_pod(id)
    end

    def refresh
      pod = kubr.get_pod(id)
      @status = case pod[:currentState][:status]
      when 'Running'
        'started'
      when 'Waiting'
        'stopped'
      else
        'error'
      end
    end

    private

    def to_pod
      {
        id: id,
        kind: 'Pod',
        apiVersion: 'v1beta1',
        desiredState: {
          manifest: {
            version: 'v1beta1',
            id: id,
            containers: [
              {
                name: name,
                image: source,
              }
            ]
          }
        },
        labels: {
          name: id
        }
      }.tap do |pod|
        pod[:desiredState][:manifest][:containers].first.tap do |c|
          c[:command] = command if command
          c[:ports] = port_mapping if ports.any?
          c[:env] = environment_mapping if environment.any?
        end
      end
    end

    def port_mapping
      ports.map do |port|
        {
          hostPort: port['hostPort'],
          containerPort: port['containerPort'],
          protocol: port['protocol'].upcase || 'TCP'
        }
      end
    end

    def environment_mapping
      environment.map do |env|
        {
          name: env['variable'],
          value: env['value']
        }
      end
    end

    def kubr
      @kubr ||= Kubr::Client.new
    end

  end
end
