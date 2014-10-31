require 'spec_helper'

describe KubernetesAdapter::Routes::Metadata do

  describe 'GET /metadata' do

    it 'returns version metadata' do
      expected = {
        version: KubernetesAdapter::IMPL_VERSION,
        type: KubernetesAdapter::TYPE
      }.to_json

      get '/v1/metadata'
      expect(last_response.body).to eq expected
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
  end
end
