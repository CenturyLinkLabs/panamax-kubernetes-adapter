require 'spec_helper'

describe KubernetesAdapter::Routes::Services do

  let(:id) { '123' }

  describe 'POST /services' do

    let(:service_name) { 'myservice' }

    let(:request_body) do
      [
        { name: service_name, source: 'foo/bar' }
      ].to_json
    end

    before do
      allow_any_instance_of(Pod).to receive(:start)
    end

    it 'starts the services' do
      expect_any_instance_of(Pod).to receive(:start).exactly(:once)
      post '/services', request_body
    end

    it 'returns an array of service IDs' do
      expected = [{ id: "#{service_name}-pod" }].to_json

      post '/services', request_body
      expect(last_response.body).to eq expected
    end

    it 'has an application/json Content-Type' do
      post '/services', request_body
      expect(last_response.headers['Content-Type']).to eq 'application/json'
    end

    it 'returns a 201 status' do
      post '/services', request_body
      expect(last_response.status).to eq 201
    end
  end

  describe 'GET /services/:id' do

    let(:model) { Pod.new(id: id) }
    let(:status) { 'running' }

    before do
      allow(KubernetesModel).to receive(:find).and_return(model)
      allow(model).to receive(:status).and_return(status)
    end

    it 'returns the status formatted as JSON' do
      expected = { id: model.id, actualState: model.status }.to_json

      get "/services/#{id}"
      expect(last_response.body).to eq expected
    end

    it 'has an application/json Content-Type' do
      get "/services/#{id}"
      expect(last_response.headers['Content-Type']).to eq 'application/json'
    end

    it 'returns a 200 status' do
      get "/services/#{id}"
      expect(last_response.status).to eq 200
    end

    context 'when the service cannot be found' do

      before do
        allow(KubernetesModel).to receive(:find)
          .and_raise(RestClient::ResourceNotFound)
      end

      it 'returns a 404 status' do
        get "/services/#{id}"
        expect(last_response.status).to eq 404
      end
    end
  end

  describe 'PUT /services/:id' do

    it 'returns a 501 status' do
      put "/services/#{id}"
      expect(last_response.status).to eq 501
    end
  end

  describe 'DELETE /services/:id' do

    let(:model) { Pod.new }

    before do
      allow(KubernetesModel).to receive(:find).and_return(model)
      allow(model).to receive(:destroy)
    end

    it 'finds the model with the given id' do
      expect(KubernetesModel).to receive(:find).with(id)
      delete "/services/#{id}"
    end

    it 'destroys the model' do
      expect(model).to receive(:destroy)
      delete "/services/#{id}"
    end

    it 'returns a 204 status' do
      delete "/services/#{id}"
      expect(last_response.status).to eq 204
    end
  end
end