module KubernetesAdapter
  module Routes
    class Metadata < Base

      get '/v1/metadata' do
        json version: KubernetesAdapter::IMPL_VERSION,
          type: KubernetesAdapter::TYPE
      end

    end
  end
end
