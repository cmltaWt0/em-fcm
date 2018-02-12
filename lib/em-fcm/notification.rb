require 'json'

module EventMachine
  module FCM
    class Notification
      attr_reader :uuid, :options, :registration_ids

      # items that can occur in the options
      VALID_TOP_LEVEL_ITEMS = [
        :time_to_live, :delay_while_idle, :collapse_key, :data, :type, :notification, :target_id, :token_platform
      ].freeze

      USER_AGENT = "em-fcm #{EM::FCM::VERSION}"

      def initialize(registration_ids, options = {})

        if registration_ids.kind_of?(String)
          registration_ids = [registration_ids]
        end

        @registration_ids, @options = registration_ids, options
        raise ArgumentError.new("missing options") if options.nil? || options.empty?

        validate_options(@options)

        @uuid = $uuid.generate
      end

      def body
        @body ||= generate_body
      end

      def headers(token)
        {
          "Authorization"   => "key=#{token}",
          "Content-Type"    => "application/json",
          "User-Agent"      => USER_AGENT
        }
      end


      private

      def validate_options(options)
        raise ArgumentError.new("Invalid time_to_live, must be a non-negative integer") if options[:time_to_live] && !options[:time_to_live].kind_of?(Numeric)

        # don't bother validating anything else, the fcm request will barf if you have bad params
        options.each_key { |key|
          raise "Invalid item in options hash: #{key}" unless VALID_TOP_LEVEL_ITEMS.include?(key)
        }

      end

      def generate_body
        body_hash = {}
        body_hash[:registration_ids] = @registration_ids
        body_hash = body_hash.merge(@options)
        body_hash.to_json
      end

    end
  end
end
