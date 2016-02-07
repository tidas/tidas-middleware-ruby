module Tidas
  class SuccessfulResult

    attr_reader :tidas_id, :data, :message

    def initialize(attributes = {}) # :nodoc:
      @tidas_id = attributes[:tidas_id]
      @data     = attributes[:data]
      @message  = attributes[:message]
    end

    def success?
      true
    end

  end
end
