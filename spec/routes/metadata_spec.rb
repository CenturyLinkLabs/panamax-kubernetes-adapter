require 'spec_helper'

describe KubernetesAdapter::Routes::Metadata do

  describe 'GET /metadata' do

    before do
      stub_const('KubernetesAdapter::IMPL_VERSION', '0.1.0')
      allow_any_instance_of(Kubr::Client).to receive(:list_minions)
    end

    it 'has an application/json Content-Type' do
      get '/v1/metadata'
      expect(last_response.headers['Content-Type']).to eq 'application/json'
    end

    it 'includes version in X-Adapter-Version header' do
      get '/v1/metadata'
      expect(last_response.headers['X-Adapter-Version']).to eq(
        KubernetesAdapter::IMPL_VERSION)
    end

    it 'returns a 200 status' do
      get '/v1/metadata'
      expect(last_response.status).to eq 200
    end

    context 'when Kubernetes is healthy' do

      it 'returns metadata with a healthy status' do
        expected = {
          version: KubernetesAdapter::IMPL_VERSION,
          type: KubernetesAdapter::TYPE,
          isHealthy: true
        }.to_json

        get '/v1/metadata'
        expect(last_response.body).to eq expected
      end
    end

    context 'when Kubernetes is not healthy' do

      before do
        allow_any_instance_of(Kubr::Client).to receive(:list_minions)
          .and_raise('boom')
      end

      it 'returns metadata with an un-healthy status' do
        expected = {
          version: KubernetesAdapter::IMPL_VERSION,
          type: KubernetesAdapter::TYPE,
          isHealthy: false
        }.to_json

        get '/v1/metadata'
        expect(last_response.body).to eq expected
      end
    end

  end
end
