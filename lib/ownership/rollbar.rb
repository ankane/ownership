module Ownership
  module Rollbar
    class << self
      attr_reader :access_token

      def access_token=(access_token)
        @access_token = access_token
        @configure ||= configure # just once
        access_token
      end

      private

      def owner_access_token(owner)
        access_token.respond_to?(:call) ? access_token.call(owner) : access_token[owner]
      end

      def configure
        ::Rollbar.configure do |config|
          config.before_process << proc do |options|
            options[:scope][:ownership_owner] = Ownership.owner if Ownership.owner
          end

          config.transform << proc do |options|
            # clean up payload
            options[:payload]["data"].delete(:ownership_owner)

            owner = options[:exception].owner if options[:exception].respond_to?(:owner)
            unless owner
              owner = options[:scope][:ownership_owner] if options[:scope].is_a?(Hash)
              owner ||= Ownership.default_owner
            end

            if owner
              access_token = owner_access_token(owner)
              if access_token
                options[:payload]["access_token"] = access_token
              else
                warn "[ownership] Missing Rollbar access token for owner: #{owner}"
              end
            end
          end
        end
        true
      end
    end
  end
end
