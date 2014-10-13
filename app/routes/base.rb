module KubernetesAdapter
  module Routes
    class Base < Sinatra::Application

      before do
        headers 'Content-Type' => 'application/json'
      end

      error RestClient::ResourceNotFound do
        status 404
      end

    end
  end
end
