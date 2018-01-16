module EventMachine
  module FCM
    class LogMessage
      def initialize(notification, response)
        @notification, @response = notification, response
      end

      def log
        if @response.success?
          EM::FCM.logger.info(message)
        else
          EM::FCM.logger.error(message)
        end
      end

      private

      def message
        parts = [
          "CODE=#{@response.status}",
          "GUID=#{@notification.uuid}",
          "TOKEN=#{@notification.registration_ids}",
          "TIME=#{@response.duration}"
        ]
        parts << "ERROR=#{@response.error}" unless @response.success?
        parts.join(" ")
      end
    end
  end
end
