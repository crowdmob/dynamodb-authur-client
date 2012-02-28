module Dynamodb
  module Authur
    module Client
      module Controllers
        # Create url helpers to be used with resource/scope configuration. Acts as
        # proxies to the generated routes created by dynamodb_authur_client.
        # Resource param can be a string or symbol, a class, or an instance object.
        # Example using a :user resource:
        #
        #   new_session_url(:user)      => new_user_session_url
        #   session_url(:user)          => user_session_url
        #   destroy_session_url(:user)  => destroy_user_session_url
        #
        #   new_password_url(:user)     => new_user_password_url
        #   password_url(:user)         => user_password_url
        #   edit_password_url(:user)    => edit_user_password_url
        #
        #   new_confirmation_url(:user) => new_user_confirmation_url
        #   confirmation_url(:user)     => user_confirmation_url
        #
        # Those helpers are included by default to ActionController::Base.
        #
        # In case you want to add such helpers to another class, you can do
        # that as long as this new class includes both url_helpers and
        # mounted_helpers. Example:
        #
        #     include Rails.application.routes.url_helpers
        #     include Rails.application.routes.mounted_helpers
        #
        module UrlHelpers
          def self.remove_helpers!
            self.instance_methods.map(&:to_s).grep(/_(url|path)$/).each do |method|
              remove_method method
            end
          end

          def self.generate_helpers!(routes=nil)
            routes ||= begin
              mappings = Dynamodb::Authur::Client.mappings.values.map(&:used_helpers).flatten.uniq
              Dynamodb::Authur::Client::URL_HELPERS.slice(*mappings)
            end

            routes.each do |module_name, actions|
              [:path, :url].each do |path_or_url|
                actions.each do |action|
                  action = action ? "#{action}_" : ""
                  method = "#{action}#{module_name}_#{path_or_url}"

                  class_eval <<-URL_HELPERS, __FILE__, __LINE__ + 1
                    def #{method}(resource_or_scope, *args)
                      scope = Dynamodb::Authur::Client::Mapping.find_scope!(resource_or_scope)
                      _dynamodb_authur_client_route_context.send("#{action}\#{scope}_#{module_name}_#{path_or_url}", *args)
                    end
                  URL_HELPERS
                end
              end
            end
          end

          generate_helpers!(Dynamodb::Authur::Client::URL_HELPERS)

          private

          def _dynamodb_authur_client_route_context
            @_dynamodb_authur_client_route_context ||= send(Dynamodb::Authur::Client.available_router_name)
          end
        end
      end
    end
  end
end
