module EventMachine
  module FCM

    class FCM

      def push(registration_ids, options, &block)
        notification = Notification.new(registration_ids, options)
        Client.new(self, notification).deliver(block)
      end

      def token=(token)
        EventMachine::FCM::logger.info("setting new auth token")
        @token = token
      end

      def token
        @token
      end

    end

  end
end
