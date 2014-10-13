require 'spec_helper'

describe KubernetesAdapter::Models::Pod do

  let(:attrs) do
    {
      name: 'foo',
      id: 'foo1',
      image: 'bar',
      command: '/bin/bash',
      ports: [{ containerPort: 8080 }],
      environment: [{ variable: 'PASSWORD', value: 'password' }]
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

  describe '.find' do

    let(:id) { 123 }

    before do
      allow(client).to receive(:get_pod).and_return(
        { currentState: { status: 'started' } })
    end

    it 'queries the pod for status' do
      expect(client).to receive(:get_pod).with(id)
      described_class.find(id)
    end

    it 'returns a Pod instance' do
      pod = described_class.find(id)
      expect(pod.id).to eq id
    end
  end

  describe '#initialize' do

    context 'when no attrs are specified' do

      it 'initializes an empty object' do
        pod = described_class.new

        expect(pod.name).to be_nil
        expect(pod.id).to be_nil
        expect(pod.image).to be_nil
        expect(pod.command).to be_nil
        expect(pod.ports).to eq []
        expect(pod.environment).to eq []
      end
    end

    context 'when attrs are specified' do
      it 'initializes the pod with the attrs' do
        pod = described_class.new(attrs)

        expect(pod.name).to eq attrs[:name]
        expect(pod.id).to eq attrs[:id]
        expect(pod.image).to eq attrs[:image]
        expect(pod.command).to eq attrs[:command]
        expect(pod.ports).to eq attrs[:ports]
        expect(pod.environment).to eq attrs[:environment]
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
        expect(subject.id).to eq "#{name}-pod"
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

      subject { described_class.new(name: 'foo', image: 'bar') }

      it 'sends the appropriate representation to the k8s API' do
        expected = {
          id: 'foo-pod',
          kind: 'Pod',
          apiVersion: 'v1beta1',
          desiredState: {
            manifest: {
              id: 'foo-pod',
              version: 'v1beta1',
              containers: [
                { name: 'foo', image: 'bar'}
              ]
            }
          },
          labels: { name: 'foo'}
        }

        expect(client).to receive(:create_pod).with(expected)

        subject.start
      end
    end

    context 'when all attributes are specified' do

      subject { described_class.new(attrs.except(:id)) }

      it 'sends the appropriate representation to the k8s API' do
        expected = {
          id: "#{attrs[:name]}-pod",
          kind: 'Pod',
          apiVersion: 'v1beta1',
          desiredState: {
            manifest: {
              id: "#{attrs[:name]}-pod",
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
          labels: { name: 'foo'}
        }

        expect(client).to receive(:create_pod).with(expected)

        subject.start
      end
    end
  end

  context '#destroy' do
    it 'invokes delete_pod on the Kubr client' do
      expect(client).to receive(:delete_pod).with(attrs[:id])
      subject.destroy
    end
  end

  context '#refresh' do

    before do
      allow(client).to receive(:get_pod).and_return({ currentState: {} })
    end

    it 'invokes get_pod on the Kubr client' do
      expect(client).to receive(:get_pod).with(subject.id)
      subject.refresh
    end

    context "when pod status is 'Running'" do

      before do
        allow(client).to receive(:get_pod).and_return(
          { currentState: { status: 'Running' } })
      end

      it "sets the status to 'started'" do
        subject.refresh
        expect(subject.status).to eq 'started'
      end
    end

    context "when pod status is 'Waiting'" do

      before do
        allow(client).to receive(:get_pod).and_return(
          { currentState: { status: 'Waiting' } })
      end

      it "sets the status to 'stopped'" do
        subject.refresh
        expect(subject.status).to eq 'stopped'
      end
    end

    context "when pod status is something else" do

      before do
        allow(client).to receive(:get_pod).and_return(
          { currentState: { status: 'Foo' } })
      end

      it "sets the status to 'error'" do
        subject.refresh
        expect(subject.status).to eq 'error'
      end
    end
  end

end
