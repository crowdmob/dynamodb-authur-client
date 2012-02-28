module Dynamodb
  module Authur
    module Client
      # Checks the scope in the given environment and returns the associated failure app.
      class Delegator
        def call(env)
          failure_app(env).call(env)
        end

        def failure_app(env)
          app = env["warden.options"] &&
            (scope = env["warden.options"][:scope]) &&
            Dynamodb::Authur::Client.mappings[scope.to_sym].failure_app

          app || Dynamodb::Authur::Client::FailureApp
        end
      end
    end
  end
end
