module KubernetesAdapter
  module Routes
    class Services < Base

      post '/services' do
        services = Service.create_all(@payload)
        entities = KubernetesModel.create_all(services)
        entities.each(&:start)

        status 201
        json entities.map { |entity| { id: entity.id } }
      end

      get '/services/:id' do
        entity = KubernetesModel.find(params[:id])
        json({ id: entity.id, actualState: entity.status })
      end

      put '/services/:id' do
        status 501
      end

      delete '/services/:id' do
        KubernetesModel.find(params[:id]).destroy
        status 204
      end
    end
  end
end
