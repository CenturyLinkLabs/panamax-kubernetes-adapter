module KubernetesAdapter
  module Routes
    class Services < Base

      using KubernetesAdapter::SymbolExtensions

      before do
        if request.request_method == "POST"
          @payload = JSON.parse(request.body.read).symbolize_hash_keys
        end
      end

      post '/v1/services' do
        services = Service.create_all(@payload)
        entities = KubernetesModel.create_all(services)
        started = []

        begin
          entities.each do |entity|
            entity.start
            started << entity
          end

          status 201
          json entities.map { |entity| { id: entity.id } }
        rescue RestClient::Exception => ex
          log_exception(ex)
          started.each(&:destroy) rescue nil
          status ex.is_a?(RestClient::Conflict) ? 409 : 500
          json(message: ex.message)
        end
      end

      get '/v1/services/:id' do
        entity = KubernetesModel.find(params[:id])
        json({ id: entity.id, actualState: entity.status })
      end

      put '/v1/services/:id' do
        status 501
      end

      delete '/v1/services/:id' do
        KubernetesModel.find(params[:id]).destroy
        status 204
      end
    end
  end
end
