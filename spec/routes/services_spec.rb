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
      post '/v1/services', request_body
    end

    it 'returns an array of service IDs' do
      expected = [{ id: "#{service_name}-pod" }].to_json

      post '/v1/services', request_body
      expect(last_response.body).to eq expected
    end

    it 'has an application/json Content-Type' do
      post '/v1/services', request_body
      expect(last_response.headers['Content-Type']).to eq 'application/json'
    end

    it 'returns a 201 status' do
      post '/v1/services', request_body
      expect(last_response.status).to eq 201
    end

    context 'when an error occurs starting a service' do

      before do
        allow_any_instance_of(Pod).to receive(:start)
          .and_raise(RestClient::Exception)

        allow_any_instance_of(Pod).to receive(:destroy)
      end

      it 'returns a 500 response code' do
        post '/v1/services', request_body
        expect(last_response.status).to eq 500
      end

      it 'returns JSON message' do
        post '/v1/services', request_body
        expect(last_response.body).to eq({ message: 'RestClient::Exception' }.to_json)
      end

      it 'logs the exception' do
        expect_any_instance_of(Logger).to receive(:error)
        post '/v1/services', request_body
      end
    end

    context 'when one of N services fails to start' do

      let(:good_service) { double(:good_service) }
      let(:bad_service) { double(:bad_service) }

      before do
        allow(good_service).to receive(:start)
        allow(good_service).to receive(:destroy)
        allow(bad_service).to receive(:start).and_raise(RestClient::Exception)
        allow(KubernetesModel).to receive(:create_all)
          .and_return([good_service, bad_service])
      end

      it 'cleans up the started services' do
        expect(good_service).to receive(:destroy)
        post '/v1/services', request_body
      end

      it 'does not clean up the failed services' do
        expect(bad_service).to_not receive(:destroy)
        post '/v1/services', request_body
      end

      it 'returns a 500 response code' do
        post '/v1/services', request_body
        expect(last_response.status).to eq 500
      end

      it 'returns JSON message' do
        post '/v1/services', request_body
        expect(last_response.body).to eq({ message: 'RestClient::Exception' }.to_json)
      end

      context 'when the error is a conflict' do

        before do
          allow(bad_service).to receive(:start).and_raise(RestClient::Conflict)
        end

        it 'returns a 409 response code' do
          post '/v1/services', request_body
          expect(last_response.status).to eq 409
        end
      end
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

      get "/v1/services/#{id}"
      expect(last_response.body).to eq expected
    end

    it 'has an application/json Content-Type' do
      get "/v1/services/#{id}"
      expect(last_response.headers['Content-Type']).to eq 'application/json'
    end

    it 'returns a 200 status' do
      get "/v1/services/#{id}"
      expect(last_response.status).to eq 200
    end

    context 'when the service cannot be found' do

      before do
        allow(KubernetesModel).to receive(:find)
          .and_raise(RestClient::ResourceNotFound)
      end

      it 'returns a 404 status' do
        get "/v1/services/#{id}"
        expect(last_response.status).to eq 404
      end
    end
  end

  describe 'PUT /services/:id' do

    it 'returns a 501 status' do
      put "/v1/services/#{id}"
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
      delete "/v1/services/#{id}"
    end

    it 'destroys the model' do
      expect(model).to receive(:destroy)
      delete "/v1/services/#{id}"
    end

    it 'returns a 204 status' do
      delete "/v1/services/#{id}"
      expect(last_response.status).to eq 204
    end
  end
end
