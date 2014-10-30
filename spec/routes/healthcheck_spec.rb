require 'spec_helper'

describe KubernetesAdapter::Routes::Healthcheck do

  describe 'GET /healthcheck' do

    before do
      allow_any_instance_of(Kubr::Client).to receive(:list_minions)
    end

    it 'has a text/plain Content-Type' do
      get '/healthcheck'
      expect(last_response.headers['Content-Type']).to eq 'text/plain'
    end

    it 'returns a 200 status' do
      get '/healthcheck'
      expect(last_response.status).to eq 200
    end

    context 'when Kubernetes is healthy' do
      it 'returns true' do
        get '/healthcheck'
        expect(last_response.body).to eq 'true'
      end
    end

    context 'when Kubernetes is NOT healthy' do

      before do
        allow_any_instance_of(Kubr::Client).to receive(:list_minions)
          .and_raise('oops')
      end

      it 'returns false' do
        get '/healthcheck'
        expect(last_response.body).to eq 'false'
      end
    end
  end
end
