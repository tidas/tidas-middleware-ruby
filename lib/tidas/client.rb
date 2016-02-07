require 'tidas/error_result'
require 'tidas/exceptions'

require 'faraday'

module Tidas
  module Client

    private

    def self.client
      unless server && api_key && application
        raise(ConfigurationError,"Tidas not configured: see readme for help")
      end
      @client ||= Faraday.new(url:server)
    end

    def self.server
      Configuration.server
    end

    def self.api_key
      Configuration.api_key
    end

    def self.application
      Configuration.application
    end

    def self.timeout
      Configuration.timeout.to_i
    end

    def self.ping
      wrapped_get('ping')
    end

    def self.index_identities
      wrapped_get("identities/index")
    end

    def self.get_identity(id)
      wrapped_get("identities/index", {tidas_id: id})
    end

    def self.enroll(data, id, overwrite)
      body = {}
      body[:enrollment_data] = data
      body[:tidas_id] = id if !id.to_s.empty?
      body[:overwrite] = true if overwrite

      wrapped_post('identities/enroll', body)
    end

    def self.validate(data, id = nil)

      begin
        tidas_data = Utilities::Unpacker.init_with_blob(data)
      rescue StandardError, NoMethodError
        raise(ParameterError,"Invalid data for request")
      end

      body = {}
      body[:validation_data] = tidas_data.to_s
      body[:tidas_id] = id if !id.to_s.empty?
      wrapped_post('identities/validate', body, tidas_data.parse[:data_to_sign])
    end

    def self.deactivate(id)
      body = {tidas_id: id}    
      wrapped_post('identities/deactivate', body)
    end

    def self.activate(id)
      body = {tidas_id: id}
      wrapped_post('identities/activate', body)
    end

    def self.wrapped_get(url, extra_params = nil)
      begin
        resp = get(url, extra_params)
      rescue Faraday::TimeoutError
        return TimeoutError
      rescue Faraday::ConnectionFailed
        return ConnectionError
      end
      return Utilities::ResponsePackager.package_response(resp)
    end

    def self.wrapped_post(url, body, data = nil)
      begin
        resp = post(url,body)
        if data
          return Utilities::ResponsePackager.package_response(resp, data)
        else
          return Utilities::ResponsePackager.package_response(resp)
        end
      rescue Faraday::TimeoutError
        return TimeoutError
      rescue Faraday::ConnectionFailed
        return ConnectionError
      end
    end

    def self.get(url, extra_params = nil)
      resp = client.get do |req|
        req.url url
        req.params['api_key'] = api_key
        req.params['application'] = application

        if extra_params != nil
          extra_params.each do |param, value|
            req.params[param] = value
          end
        end

        req.options[:timeout] = timeout
      end

      resp
    end

    def self.post(url, body)
      resp = client.post do |req|
        req.url url
        req.headers['Content-Type'] = 'application/json'
        req.params['api_key'] = api_key
        req.options[:timeout] = timeout

        body[:application] = application

        req.body = body.to_json
      end

      resp
    end

  end
end
