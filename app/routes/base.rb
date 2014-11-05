module KubernetesAdapter
  module Routes
    class Base < Sinatra::Application

      configure do
        set show_exceptions: false
      end

      before do
        headers 'Content-Type' => 'application/json'
        headers 'X-Adapter-Version' => KubernetesAdapter::IMPL_VERSION
      end

      error RestClient::ResourceNotFound do
        status 404
      end

      def log_exception(ex)
        log_message = "\n#{ex.class} (#{ex.message}):\n"
        log_message << "  " << ex.backtrace.join("\n  ") << "\n\n"
        logger.error(log_message)
      end
    end
  end
end
