require 'spec_helper'

describe KubernetesAdapter::Models::KubernetesModel do

  it { is_expected.to respond_to(:id) }
  it { is_expected.to respond_to(:status) }

  describe '.create_all' do

    let(:services) { double(:service) }
    let(:converter) { double(:converter) }
    let(:k_service) { double(:k_service) }
    let(:rep_controller) { double(:replication_controller) }
    let(:pod) { double(:pod) }

    before do
      allow(Converter).to receive(:new).and_return(converter)
      allow(converter).to receive(:k_services).and_return([k_service])
      allow(converter).to receive(:replication_controllers).and_return([rep_controller])
      allow(converter).to receive(:pods).and_return([pod])
    end

    it 'passes the supplied services to the converter' do
      expect(Converter).to receive(:new).with(services)
      described_class.create_all(services)
    end

    it 'returns the collected kubernetes entities' do
      result = described_class.create_all(services)
      expect(result).to match_array [k_service, rep_controller, pod]
    end
  end

  describe '.find' do

    context 'when the id ends with -pod' do

      let(:id) { 'foo-pod' }
      let(:pod) { double(:pod) }

      before do
        allow(Pod).to receive(:find).and_return(pod)
      end

      it 'looks-up the pod' do
        expect(Pod).to receive(:find).with(id)
        described_class.find(id)
      end

      it 'returns the pod' do
        expect(described_class.find(id)).to eq pod
      end
    end

    context 'when the id ends with -replication-controller' do

      let(:id) { 'foo-replication-controller' }
      let(:replication_controller) { double(:replication_controller) }

      before do
        allow(ReplicationController).to receive(:find).and_return(replication_controller)
      end

      it 'looks-up the replication controller' do
        expect(ReplicationController).to receive(:find).with(id)
        described_class.find(id)
      end

      it 'returns the replication controller' do
        expect(described_class.find(id)).to eq replication_controller
      end
    end

    context 'when the id ends with neither -pod nor -replication-controller' do

      let(:id) { 'foo' }
      let(:service) { double(:service) }

      before do
        allow(KService).to receive(:find).and_return(service)
      end

      it 'looks-up the service' do
        expect(KService).to receive(:find).with(id)
        described_class.find(id)
      end

      it 'returns the service' do
        expect(described_class.find(id)).to eq service
      end
    end
  end
end
