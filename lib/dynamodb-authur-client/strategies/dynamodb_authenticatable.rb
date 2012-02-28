require 'devise/strategies/base'

module Dynamodb
  module Authur
    module Client
      module Strategies
        # Remember the user through the remember token. This strategy is responsible
        # to verify whether there is a cookie with the session_token token, and to
        # recreate the user from this cookie if it exists. Must be called *before*
        # authenticatable.
        class DynamodbAuthenticatable < Authenticatable
          # A valid strategy for rememberable needs a session_token token in the cookies.
          def valid?
            @session_token_cookie = nil
            session_token_cookie.present?
          end

          # To authenticate a user we deserialize the cookie and attempt finding
          # the record in the database. If the attempt fails, we pass to another
          # strategy handle the authentication.
          def authenticate!
            resource = mapping.to.serialize_from_cookie(*session_token_cookie)

            if validate(resource)
              success!(resource)
            elsif !halted?
              cookies.delete(session_token_key)
              pass
            end
          end

        private

          def decorate(resource)
            super
            resource.extend_remember_period = mapping.to.extend_remember_period if resource.respond_to?(:extend_remember_period=)
          end

          def remember_me?
            true
          end

          def session_token_key
            "session_token_#{scope}_token"
          end

          def session_token_cookie
            @session_token_cookie ||= cookies.signed[session_token_key]
          end

        end
      end
    end
  end
end

Warden::Strategies.add(:dynamodb_authenticatable, Dynamodb::Authur::Client::Strategies::DynamodbAuthenticatable)