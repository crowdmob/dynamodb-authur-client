require 'rails'
require 'active_support/dependencies'


module Dynamodb
  module Authur
    module Client
      autoload :Delegator,   'dynamodb-authur-client/delegator'
      autoload :FailureApp,  'dynamodb-authur-client/failure_app'
      
      module Controllers
        autoload :Helpers, 'dynamodb-authur-client/controllers/helpers'
        autoload :UrlHelpers, 'dynamodb-authur-client/controllers/url_helpers'
      end
      
      module Strategies
        autoload :Base, 'dynamodb-authur-client/strategies/base'
        autoload :Authenticatable, 'dynamodb-authur-client/strategies/authenticatable'
      end
      
      
      # Constants which holds configuration for extensions. Those should
      # not be modified by the "developer" (this is why they are constants).
      ALL         = []
      CONTROLLERS = ActiveSupport::OrderedHash.new
      ROUTES      = ActiveSupport::OrderedHash.new
      STRATEGIES  = ActiveSupport::OrderedHash.new
      URL_HELPERS = ActiveSupport::OrderedHash.new

      # Strategies that do not require user input.
      NO_INPUT = []
      
      # True values used to check params
      TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE']
      
      # Authentication token params key name of choice. E.g. /users/sign_in?some_key=...
      # mattr_accessor :token_authentication_key
      # @@token_authentication_key = :auth_token
      
      # PRIVATE CONFIGURATION

      # Store scopes mappings.
      mattr_reader :mappings
      @@mappings = ActiveSupport::OrderedHash.new
      
      # Define a set of modules that are called when a mapping is added.
      mattr_reader :helpers
      @@helpers = Set.new
      @@helpers << Dynamodb::Authur::Client::Controllers::Helpers
      
      # Private methods to interface with Warden.
      mattr_accessor :warden_config
      @@warden_config = nil
      @@warden_config_block = nil
      
      def self.available_router_name
        router_name || :main_app
      end
      
      
      # Include helpers in the given scope to ActionController and ActionView.
      def self.include_helpers(scope)
        ActiveSupport.on_load(:action_controller) do
          include scope::Helpers if defined?(scope::Helpers)
          include scope::UrlHelpers
        end

        ActiveSupport.on_load(:action_view) do
          include scope::UrlHelpers
        end
      end
      
      # Sets warden configuration using a block that will be invoked on warden
      # initialization.
      #
      #  Dynamodb::Authur::Client.initialize do |config|
      #    config.allow_unconfirmed_access_for = 2.days
      #
      #    config.warden do |manager|
      #      # Configure warden to use other strategies, like oauth.
      #      manager.oauth(:twitter)
      #    end
      #  end
      def self.warden(&block)
        @@warden_config_block = block
      end
      
      # A method used internally to setup warden manager from the Rails initialize
      # block.
      def self.configure_warden! #:nodoc:
        @@warden_configured ||= begin
          warden_config.failure_app   = Dynamodb::Authur::Client::Delegator.new
          warden_config.default_scope = Dynamodb::Authur::Client.default_scope
          warden_config.intercept_401 = false

          Dynamodb::Authur::Client.mappings.each_value do |mapping|
            warden_config.scope_defaults mapping.name, :strategies => mapping.strategies
          end

          @@warden_config_block.try :call, Dynamodb::Authur::Client.warden_config
          true
        end
      end
      
    end
  end
end

require 'warden'
require 'dynamodb-authur-client/rails'
require "dynamodb-authur-client/version"