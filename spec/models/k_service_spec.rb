require 'spec_helper'

describe KubernetesAdapter::Models::KService do

  let(:attrs) do
    {
      name: 'foo',
      id: 'foo1',
      port: 8000,
      container_port: 80
    }
  end

  let(:client) { double(:client) }

  subject { described_class.new(attrs) }

  before do
    allow(Kubr::Client).to receive(:new).and_return(client)
  end

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:id) }
  it { is_expected.to respond_to(:port) }
  it { is_expected.to respond_to(:container_port) }

  describe '.find' do

    let(:id) { 123 }

    before do
      allow(client).to receive(:get_service)
    end

    it 'queries the service for status' do
      expect(client).to receive(:get_service).with(id)
      described_class.find(id)
    end

    it 'returns a KService instance' do
      service = described_class.find(id)
      expect(service.id).to eq id
    end
  end

  describe '#initialize' do

    context 'when no attrs are specified' do

      it 'initializes an empty object' do
        service = described_class.new

        expect(service.name).to be_nil
        expect(service.id).to be_nil
        expect(service.port).to be_nil
        expect(service.container_port).to be_nil
      end
    end

    context 'when attrs are specified' do
      it 'initializes the service with the attrs' do
        service = described_class.new(attrs)

        expect(service.name).to eq attrs[:name]
        expect(service.id).to eq attrs[:id]
        expect(service.port).to eq attrs[:port]
        expect(service.container_port).to eq attrs[:container_port]
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

      let(:name) { 'FOO_BAR' }
      subject { described_class.new(name: name) }

      it 'returns an id generated from the name' do
        expect(subject.id).to eq name
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

    context 'when a container_port is specified' do

      it 'sends the appropriate representation to the k8s API' do
        expected = {
          id: attrs[:id],
          apiVersion: 'v1beta1',
          kind: 'Service',
          port: attrs[:port],
          labels: { name: attrs[:name] },
          selector: { name: attrs[:name] },
          containerPort: attrs[:container_port]
        }

        expect(client).to receive(:create_service).with(expected)

        subject.start
      end
    end

    context 'when a container_port is NOT specified' do

      subject { described_class.new(attrs.except(:container_port)) }

      it 'sends the appropriate representation to the k8s API' do
        expected = {
          id: attrs[:id],
          apiVersion: 'v1beta1',
          kind: 'Service',
          port: attrs[:port],
          labels: { name: attrs[:name] },
          selector: { name: attrs[:name] }
        }

        expect(client).to receive(:create_service).with(expected)

        subject.start
      end
    end
  end

  context '#destroy' do
    it 'invokes delete_service on the Kubr client' do
      expect(client).to receive(:delete_service).with(attrs[:id])
      subject.destroy
    end
  end

  context '#refresh' do
    before do
      allow(client).to receive(:get_service)
    end

    it 'invokes get_service on the Kubr client' do
      expect(client).to receive(:get_service).with(attrs[:id])
      subject.refresh
    end

    it "returns 'started'" do
      expect(subject.refresh).to eq 'started'
    end
  end
end
