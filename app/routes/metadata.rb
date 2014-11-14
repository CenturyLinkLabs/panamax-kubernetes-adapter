module KubernetesAdapter
  module Routes
    class Metadata < Base

      get '/v1/metadata' do
        is_healthy = begin
                       Kubr::Client.new.list_minions
                       true
                     rescue
                       false
                     end

        json({
          version: KubernetesAdapter::IMPL_VERSION,
          type: KubernetesAdapter::TYPE,
          isHealthy: is_healthy
        })
      end

    end
  end
end
