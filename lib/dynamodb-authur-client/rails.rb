require 'dynamodb-authur-client/rails/warden_compat'

module Dynamodb
  module Authur
    module Client
      class Engine < ::Rails::Engine
        config.dynamodb_authur_client = Dynamodb::Authur::Client

        # Initialize Warden and copy its configurations.
        config.app_middleware.use Warden::Manager do |config|
          Dynamodb::Authur::Client.warden_config = config
        end

        # Force routes to be loaded if we are doing any eager load.
        config.before_eager_load { |app| app.reload_routes! }

        initializer "dynamodb_authur_client.url_helpers" do
          Dynamodb::Authur::Client.include_helpers(Dynamodb::Authur::Client::Controllers)
        end

        initializer "dynamodb_authur_client.deprecations" do
          # Currently no deprecations
        end
      end
    end
  end
end
