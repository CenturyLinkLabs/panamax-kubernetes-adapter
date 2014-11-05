require 'spec_helper'

describe KubernetesAdapter::Models::Converter do

  let(:service_a) { Service.new(name: 'a') }
  let(:service_b) { Service.new(name: 'b') }

  subject { described_class.new([service_a, service_b]) }

  it { is_expected.to respond_to(:services) }

  describe '#initialize' do

    let(:services) { [double(:service)] }

    it 'assigns the services' do
      converter = described_class.new(services)
      expect(converter.services).to eq services
    end
  end

  describe '#pods' do

    before do
      service_a.deployment = { count: 2 }
    end

    it 'returns a pod for each unscaled service' do
      pods = subject.pods

      expect(pods).to be_kind_of Array
      expect(pods.count).to eq 1
      expect(pods.first).to be_kind_of Pod
      expect(pods.first.name).to eq service_b.name
    end
  end

  describe '#replication_controllers' do

    before do
      service_a.deployment = { count: 2 }
    end

    it 'returns a replication controller for each scaled service' do
      rcs = subject.replication_controllers

      expect(rcs).to be_kind_of Array
      expect(rcs.count).to eq 1
      expect(rcs.first).to be_kind_of ReplicationController
      expect(rcs.first.name).to eq service_a.name
    end
  end

  describe '#k_services' do

    context 'when there are scaled services' do

      before do
        service_a.deployment = { count: 2 }
      end

      subject { described_class.new([service_a, service_b]) }

      context 'when the service has a mapped port' do

        before do
          service_a.ports << { hostPort: 8000, containerPort: 80 }
        end

        it 'returns a k_service for each scaled service' do
          k_services = subject.k_services

          expect(k_services).to be_kind_of Array
          expect(k_services.count).to eq 1
          expect(k_services.first).to be_kind_of KService
          expect(k_services.first.name).to eq service_a.name
          expect(k_services.first.port).to eq 8000
          expect(k_services.first.container_port).to eq 80
        end
      end

      context 'when the service has an exposed port' do

        before do
          service_a.expose << 8888
        end

        it 'returns a k_service for each scaled service' do
          k_services = subject.k_services

          expect(k_services).to be_kind_of Array
          expect(k_services.count).to eq 1
          expect(k_services.first).to be_kind_of KService
          expect(k_services.first.name).to eq service_a.name
          expect(k_services.first.port).to eq 8888
          expect(k_services.first.container_port).to eq nil
        end
      end
    end

    context 'when there are linked services' do

      let(:service_alias) { 'SERVICE_ALIAS' }

      before do
        service_a.links << { name: 'b', alias: service_alias }
      end

      it 'returns a k_service for each linked service' do
        k_services = subject.k_services

        expect(k_services).to be_kind_of Array
        expect(k_services.count).to eq 1
        expect(k_services.first).to be_kind_of KService
        expect(k_services.first.name).to eq service_b.name
        expect(k_services.first.id).to eq service_alias.downcase.gsub(/_/, '-')
      end
    end
  end
end
