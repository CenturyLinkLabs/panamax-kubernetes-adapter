require 'sinatra'
require 'kubr'
require "sinatra/reloader" if development?

#set :port, ENV['PORT']
set :bind, '0.0.0.0'

Kubr.configure do |config|
  config.url = 'http://127.0.0.1:8080/api/v1beta1'
end

module Kubr
  class Client
    def put_pod(id, pod)
      send_request :put, "pods/#{id}", pod
    end
  end
end

class Service

  attr_accessor :name, :description, :source, :command, :ports, :environment, :volumes

  def self.find(name)
    new('name' => name)
  end

  def initialize(attrs)
    self.name = attrs['name'].downcase
    self.source = attrs['source']
    self.command= attrs['command']
    self.ports = attrs['ports'] || []
    self.environment = attrs['environment'] || []
    self.volumes = attrs['volumes'] || []
  end

  def load
    puts kubr.create_pod(pod)
  end

  def start
    pod = kubr.get_pod(name)
    pod[:desiredState][:status] = 'Running'
    kubr.put_pod(name, pod)
  end

  def stop
    pod = kubr.get_pod(name)
    pod[:desiredState][:status] = 'Stopped'
    kubr.put_pod(name, pod)
  end

  # started, stopped, error
  def status
    pod = kubr.get_pod(name)
    case pod[:currentState][:status]
    when 'Running'
      'started'
    when 'Waiting'
      'stopped'
    else
      'error'
    end
  end

  def destroy
    kubr.delete_pod(name)
  end

  def pod
    {
      id: name,
      desiredState: {
        manifest: {
          version: 'v1beta1',
          id: name,
          containers: [
            {
              name: name,
              image: source,
              command: command,
              ports: port_mapping,
              env: environment_mapping
            }
          ]
        }
      },
      labels: {
        name: name
      }
    }
  end

  private

  def port_mapping
    ports.map do |port|
      {
        containerPort: port['container_port'],
        hostPort: port['host_port'],
        protocol: port['proto'].upcase || 'TCP'
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

before do
  headers 'Content-Type' => 'application/json'
end

get '/services/:id' do
  service = Service.find(params[:id])

  {
    id: service.name,
    status: service.status
  }.to_json
end

post '/services' do
  request.body.rewind
  body = JSON.parse(request.body.read)

  services = body['services'].map do |service|
    Service.new(service).tap(&:load)
  end

  services.map(&:name).to_json
end

put '/services/:id' do
  request.body.rewind
  body = JSON.parse(request.body.read)
  service = Service.find(params[:id])

  if body['desired_state'] == 'started'
    service.start
    204
  elsif body['desired_state'] == 'stopped'
    service.stop
    204
  else
    400
  end
end

delete '/services/:id' do
  begin
    Service.find(params[:id]).destroy
  rescue
  end
  204
end
