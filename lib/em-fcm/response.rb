module EventMachine
  module FCM

    # Represents a FCM response.  Since FCM requests are all multi-id requests (we're using the JSON format),
    # each response itself contains a status for each id the message was sent to.
    #
    # Based on the documentation here:
    # https://firebase.google.com/docs/cloud-messaging/
    #
    class Response

      # the http status code
      attr_reader :status

      # the number of success results
      attr_reader :success

      # the number of failure results
      attr_reader :failure

      # number of canonical ids in device_responses
      attr_reader :canonical_ids

      # id from FCM
      attr_reader :multicast_id

      # duration of the call
      attr_reader :duration

      # top level error, meaning the whole request failed
      attr_reader :error

      # hash of device_id (registration_id) -> DeviceResponse
      attr_reader :device_results

      # number of seconds the server has asked us to retry after
      attr_reader :retry_after

      def initialize(device_ids, http = {}, start = nil)
        @device_ids = device_ids
        @http = http
        @duration = Time.now.to_f - start.to_f if start

        @success = 0
        @failure = 0
        @canonical_ids = 0
        @multicast_id = 0

        if http.kind_of?(Hash)
          @status = http[:status]
          @error  = http[:error]
          @retry_after = http[:retry_after]

          # allows us to simulate body parsing
          parse_body(http[:body]) if http[:body]
        else
          parse_headers(http.response_header)

          # only parse the body on a 200
          parse_body(http.response) if @status == 200
        end

      end

      def success?
        @error.nil?
      end

      private

      def parse_body(body)
        begin
          @body = JSON.parse(body, :symbolize_names => true)

          @success = @body[:success]
          @failure = @body[:failure]
          @canonical_ids = @body[:canonical_ids]
          @multicast_id = @body[:multicast_id]

          @device_results = {}
          if @body[:results] && @body[:results].size == @device_ids.size

            @device_ids.each_with_index { |device_id, index|
              result = @body[:results][index]
              device_result = DeviceResult.new(result)
              @device_results[device_id] = device_result
            }

          end

        rescue => e
          EventMachine::FCM::logger.warn("Could not parse body, it's not JSON as we expected it to be")
          @body = nil
        end
      end

      # These are messed up because of EM::HttpRequest's messed up parsing
      def parse_headers(headers)
        @status = headers.status
        @retry_after = headers["RETRY_AFTER"].to_i

        case @status
        when 200
          # noop
        when 400
          # json couldn't be parsed
          @error = "BadJSON"
        when 401
          @error = "InvalidToken"
        when [500..599]
          @error = "InternalServerError"
        else
          @error = "Unknown error: #{headers.status} (#{@http.response})"
        end
      end
    end

    # represents the result for an individual device
    class DeviceResult

      attr_reader :message_id, :registration_id, :error

      def initialize(resp)
        @message_id = resp[:message_id]
        @registration_id = resp[:registration_id]
        @error = resp[:error]
      end

    end

  end
end
