module Tidas

  class ErrorResult

    attr_reader :tidas_id, :errors, :message

    def initialize(attributes = {}) # :nodoc:
      @tidas_id = attributes[:tidas_id]
      @errors   = Array(attributes[:errors])
    end

    def success?
      false
    end

    def msg
      @errors.first
    end

    def to_json
      {
        error_result: {
          tidas_id: @tidas_id,
          errors: @errors.map(&:to_s)
        }
      }.to_json
    end

  end

  ConnectionError = ErrorResult.new(errors: "Could not connect to server")

  TimeoutError = ErrorResult.new(errors: "Request Timeout")

  class ServerError < ErrorResult
  end

  InvalidResponse = ServerError.new(errors: "Invalid response received from server - we're on it!")
end
