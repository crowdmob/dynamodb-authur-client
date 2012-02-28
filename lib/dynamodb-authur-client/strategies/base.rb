module Dynamodb
  module Authur
    module Client
      module Strategies
        # Base strategy for Dynamodb::Authur::Client. Responsible for verifying correct scope and mapping.
        class Base < ::Warden::Strategies::Base
          # Checks if a valid scope was given for dynamodb-authur-client and find mapping based on this scope.
          def mapping
            @mapping ||= begin
              mapping = Dynamodb::Authur::Client.mappings[scope]
              raise "Could not find mapping for #{scope}" unless mapping
              mapping
            end
          end
        end
      end
    end
  end
end