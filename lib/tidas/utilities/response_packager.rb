module Tidas
  module Utilities
    module ResponsePackager

      def self.package_response(response, data = nil)
        if [500, 404].include? response.status
          return InvalidResponse
        end
        begin
          body = JSON.parse(response.body, symbolize_names: true)
          return handle_result(body, data)
        rescue JSON::ParserError
          return InvalidResponse
        end
        return InvalidResponse
      end

      def self.handle_result(body, data = nil)
        result_type = body.keys[0]
        content = body[result_type]
        case result_type
          when :error_result
            return ErrorResult.new(tidas_id:content[:tidas_id], errors:content[:errors])
          when :successful_result
            if content[:returned_data] != nil
              return SuccessfulResult.new(tidas_id:content[:tidas_id], data:content[:returned_data], message:content[:message])
            else
              return SuccessfulResult.new(tidas_id:content[:tidas_id], data:data, message:content[:message])
            end
          else
            return InvalidResponse
        end
      end
    end
  end
end
