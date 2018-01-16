require "em-fcm/response"
require "em-fcm/log_message"

module EventMachine
  module FCM
    class Client
      URL = "https://fcm.googleapis.com/fcm/send".freeze

      def initialize(fcm, notification)
        @fcm = fcm
        @notification = notification
      end


     def deliver(block = nil)
        verify_token
        @start = Time.now.to_f

        params = {:dry_run => "true"}

        http = EventMachine::HttpRequest.new(URL).post(
          #uncomment this if you want to test send and do not want receiver to receive message
          #:query => params,
          :body => @notification.body,
          :head   => @notification.headers(@fcm.token)
        )

        http.callback do
          response = Response.new(@notification.registration_ids, http, @start)
          LogMessage.new(@notification, response).log
          block.call(response) if block
        end

        http.errback do |e|
          EM::FCM.logger.error(e.inspect)
        end
      end

      private

      def verify_token
        raise "token not set!" unless @fcm.token
      end
    end
  end
end
