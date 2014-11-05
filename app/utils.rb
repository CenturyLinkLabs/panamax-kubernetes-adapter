module KubernetesAdapter

  module SymbolExtensions
    refine Array do
      def symbolize_hash_keys
        map { |item| item.symbolize_hash_keys }
      end
    end

    refine Hash do
      def symbolize_hash_keys
        each_with_object({}) do |(key, value), h|
          h[key.to_sym] = value.symbolize_hash_keys
        end
      end
    end

    refine Object do
      def symbolize_hash_keys
        self
      end
    end
  end

  module StringExtensions
    refine String do
      def sanitize
        gsub(/[\W_]/, '-').downcase
      end
    end
  end
end
