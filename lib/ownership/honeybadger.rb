module Ownership
  module Honeybadger
    class << self
      attr_reader :api_keys

      def api_keys=(api_keys)
        @api_keys = api_keys
        @configuration ||= configure
        api_keys
      end

      private

      def add_owner_as_tag(notice, current_owner)
        return unless current_owner

        notice.tags << current_owner.to_s
      end

      def configure
        ::Honeybadger.configure do |config|
          config.before_notify do |notice|
            current_owner = notice.exception.owner if notice.exception.is_a?(Exception)
            current_owner ||= Ownership.owner

            add_owner_as_tag(notice, current_owner)
            use_owner_api_key(notice, current_owner)
          end
        end
      end

      def owner_api_key(current_owner)
        api_keys.respond_to?(:call) ? api_keys.call(current_owner) : api_keys[current_owner]
      end

      def use_owner_api_key(notice, current_owner)
        return unless current_owner

        if (api_key = owner_api_key(current_owner))
          notice.api_key = api_key
        else
          warn "[ownership] Missing Honeybadger API key for owner: #{current_owner}"
        end
      end
    end
  end
end
