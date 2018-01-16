$:.unshift File.dirname(__FILE__)

require "eventmachine"
require "em-http-request"
require "logger"
require "uuid"
require "em-fcm/version"
require "em-fcm/fcm"
require "em-fcm/client"
require "em-fcm/notification"
require "em-fcm/response"

$uuid = UUID.new

module EventMachine
  module FCM
    class << self
      def logger
        @logger ||= Logger.new(STDOUT)
      end

      def logger=(new_logger)
        @logger = new_logger
      end
    end
  end
end
