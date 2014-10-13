module KubernetesAdapter
  module Routes
    class Base < Sinatra::Application

      before do
        headers 'Content-Type' => 'application/json'
      end

      before do
        @payload = symbolize_keys(JSON.parse(request.body.read)) rescue nil
      end

      error RestClient::ResourceNotFound do
        status 404
      end

      private

      def symbolize_keys(obj)
        case obj
        when Array
          obj.map { |item| symbolize_keys(item) }
        when Hash
          obj.each_with_object({}) do |(key, value), h|
            h[key.to_sym] = symbolize_keys(value)
          end
        else
          obj
        end
      end

    end
  end
end
