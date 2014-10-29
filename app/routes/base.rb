module KubernetesAdapter
  module Routes
    class Base < Sinatra::Application

      configure do
        set show_exceptions: false
      end

      before do
        headers 'Content-Type' => 'application/json'
      end

      error RestClient::ResourceNotFound do
        status 404
      end

    end
  end
end
