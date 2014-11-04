require 'spec_helper'

describe KubernetesAdapter::Models::ReplicationController do

  let(:attrs) do
    {
      name: 'foo',
      id: 'foo1',
      image: 'bar',
      command: '/bin/bash',
      ports: [{ containerPort: 8080 }],
      environment: [{ variable: 'PASSWORD', value: 'password' }],
      replicas: 10
    }
  end

  let(:client) { double(:client) }

  subject { described_class.new(attrs) }

  before do
    allow(Kubr::Client).to receive(:new).and_return(client)
  end

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:id) }
  it { is_expected.to respond_to(:image) }
  it { is_expected.to respond_to(:command) }
  it { is_expected.to respond_to(:ports) }
  it { is_expected.to respond_to(:environment) }
  it { is_expected.to respond_to(:replicas) }

  describe '.find' do

    let(:id) { 123 }

    before do
      allow(client).to receive(:get_replication_controller)
    end

    it 'tries to find the replication controller' do
      expect(client).to receive(:get_replication_controller).with(id)
      described_class.find(id)
    end

    it 'returns a replication controller instance' do
      rc = described_class.find(id)
      expect(rc.id).to eq id
    end
  end

  describe '#initialize' do

    context 'when no attrs are specified' do

      it 'initializes an empty object' do
        rc = described_class.new

        expect(rc.name).to be_nil
        expect(rc.id).to be_nil
        expect(rc.image).to be_nil
        expect(rc.command).to be_nil
        expect(rc.ports).to eq []
        expect(rc.environment).to eq []
        expect(rc.replicas).to be_nil
      end
    end

    context 'when attrs are specified' do
      it 'initializes the replication controller with the attrs' do
        rc = described_class.new(attrs)

        expect(rc.name).to eq attrs[:name]
        expect(rc.id).to eq attrs[:id]
        expect(rc.image).to eq attrs[:image]
        expect(rc.command).to eq attrs[:command]
        expect(rc.ports).to eq attrs[:ports]
        expect(rc.environment).to eq attrs[:environment]
        expect(rc.replicas).to eq attrs[:replicas]
      end
    end
  end

  describe '#id' do

    context 'when id is set explicitly' do

      let(:id) { 'foo' }
      subject { described_class.new(id: id) }

      it 'returns the id' do
        expect(subject.id).to eq id
      end
    end

    context 'when name is set but not the ID' do

      let(:name) { 'foo' }
      subject { described_class.new(name: name) }

      it 'returns an id generated from the name' do
        expect(subject.id).to eq "#{name}-replication-controller"
      end
    end

    context 'when neither the name nor ID is set' do

      subject { described_class.new }

      it 'returns nil' do
        expect(subject.id).to be_nil
      end
    end
  end

  context '#start' do

    context 'when minimal attributes are specified' do

      subject { described_class.new(name: 'foo', image: 'bar', replicas: 2) }

      it 'sends the appropriate representation to the k8s API' do
        expected = {
          id: 'foo-replication-controller',
          kind: 'ReplicationController',
          apiVersion: 'v1beta1',
          desiredState: {
            replicas: 2,
            replicaSelector: { name: 'foo' },
            podTemplate: {
              desiredState: {
                manifest: {
                  id: 'foo-replication-controller',
                  version: 'v1beta1',
                  containers: [
                    { name: 'foo', image: 'bar'}
                  ]
                }
              },
              labels: { name: 'foo'}
            }
          },
          labels: { name: 'foo'}
        }

        expect(client).to receive(:create_replication_controller).with(expected)

        subject.start
      end
    end

    context 'when aall attributes are specified' do

      subject { described_class.new(attrs.except(:id)) }

      it 'sends the appropriate representation to the k8s API' do
        expected = {
          id: "#{attrs[:name]}-replication-controller",
          kind: 'ReplicationController',
          apiVersion: 'v1beta1',
          desiredState: {
            replicas: attrs[:replicas],
            replicaSelector: { name: attrs[:name] },
            podTemplate: {
              desiredState: {
                manifest: {
                  id: "#{attrs[:name]}-replication-controller",
                  version: 'v1beta1',
                  containers: [
                    {
                      name: attrs[:name],
                      image: attrs[:image],
                      command: attrs[:command],
                      ports: [{
                        hostPort: attrs[:ports].first[:containerPort],
                        containerPort: attrs[:ports].first[:containerPort],
                        protocol: 'TCP'
                      }],
                      env: [{
                        name: attrs[:environment].first[:variable],
                        value: attrs[:environment].first[:value]
                      }]
                    }
                  ]
                }
              },
              labels: { name: attrs[:name]}
            }
          },
          labels: { name: attrs[:name]}
        }

        expect(client).to receive(:create_replication_controller).with(expected)

        subject.start
      end
    end
  end

  context '#stop' do
    let(:rc) { { desiredState: {} } }

    before do
      allow(client).to receive(:get_replication_controller).and_return(rc)
      allow(client).to receive(:update_replication_controller)
    end

    it 'scales the replication controller to 0' do
      expect(client).to receive(:update_replication_controller) do |id, rc|
        expect(id).to eq attrs[:id]
        expect(rc).to eq({ desiredState: { replicas: 0 } })
      end

      subject.stop
    end
  end

  context '#destroy' do
    before do
      allow(subject).to receive(:stop)
      allow(client).to receive(:delete_replication_controller)
    end

    it 'stops the replication controller' do
      expect(subject).to receive(:stop)
      subject.destroy
    end

    it 'invokes delete_replication_controller on the Kubr client' do
      expect(client).to receive(:delete_replication_controller).with(attrs[:id])
      subject.destroy
    end
  end

  context '#refresh' do
    before do
      allow(client).to receive(:get_replication_controller)
    end

    it 'invokes get_replication_controller on the Kubr client' do
      expect(client).to receive(:get_replication_controller).with(attrs[:id])
      subject.refresh
    end

    it "returns 'started'" do
      expect(subject.refresh).to eq 'started'
    end
  end

end
