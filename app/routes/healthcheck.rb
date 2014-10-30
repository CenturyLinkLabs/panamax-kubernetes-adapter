module KubernetesAdapter
  module Routes
    class Healthcheck < Base

      get '/healthcheck' do
        headers 'Content-Type' => 'text/plain'

        begin
          Kubr::Client.new.list_minions
          'true'
        rescue
          'false'
        end
      end

    end
  end
end
