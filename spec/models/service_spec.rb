require 'spec_helper'

describe KubernetesAdapter::Models::Service do

  let(:attrs) do
    {
      name: 'foo',
      source: 'bar',
      command: '/bin/bash',
      ports: [{ port: 8080 }],
      environment: [{ variable: 'PASSWORD', value: 'password' }],
      volumes: [{ path: '/a/b' }],
      links: [{ service: 'other', alias: 'db' }],
      deployment: { count: 10 }
    }
  end

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:source) }
  it { is_expected.to respond_to(:command) }
  it { is_expected.to respond_to(:ports) }
  it { is_expected.to respond_to(:environment) }
  it { is_expected.to respond_to(:volumes) }
  it { is_expected.to respond_to(:links) }
  it { is_expected.to respond_to(:deployment) }

  describe '#initialize' do

    context 'when no attrs are specified' do

      it 'initializes an empty object' do
        service = described_class.new

        expect(service.name).to be_nil
        expect(service.source).to be_nil
        expect(service.command).to be_nil
        expect(service.ports).to eq []
        expect(service.environment).to eq []
        expect(service.volumes).to eq []
        expect(service.links).to eq []
        expect(service.deployment).to eq({})
      end
    end

    context 'when attrs are specified' do

      it 'initializes the service with the attrs' do
        service = described_class.new(attrs)

        expect(service.name).to eq attrs[:name]
        expect(service.source).to eq attrs[:source]
        expect(service.command).to eq attrs[:command]
        expect(service.ports).to eq attrs[:ports]
        expect(service.environment).to eq attrs[:environment]
        expect(service.volumes).to eq attrs[:volumes]
        expect(service.links).to eq attrs[:links]
        expect(service.deployment).to eq attrs[:deployment]
      end
    end
  end

  describe '#scale' do

    context 'when a deployment hash has been specified' do

      let(:count) { 10 }
      subject { described_class.new(deployment: { count: count }) }

      it 'returns the deployment count' do
        expect(subject.scale).to eq count
      end
    end

    context 'when no deployment hash has been specified' do
      it 'returns the deployment count' do
        expect(subject.scale).to eq 1
      end
    end
  end

end
