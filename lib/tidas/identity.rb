require 'tidas/exceptions'

module Tidas
  class Identity

    attr_reader :id, :deactivated, :app_name, :public_key

    def self.index
      resp = Client.index_identities
      process_identity_response(resp)
    end

    def self.get(id)
      resp = Client.get_identity(id)
      process_identity_response(resp)
    end

    def self.process_identity_response(resp)
      if resp.success?
        request_identities(resp)
      else
        resp
      end
    end

    def self.request_identities(resp)
      identities_data = JSON.parse(resp.data, symbolize_names: true)
      identities_array = identities_data[:identities]
      identities_array.map! do |identity_hash|
        Identity.new(
          id:identity_hash[:id],
          deactivated: identity_hash[:deactivated],
          app_name: identity_hash[:app],
          public_key: identity_hash[:public_key]
        )
      end

      if identities_array.length == 1
        out = identities_array[0]
      else
        out = identities_array
      end

      SuccessfulResult.new(message:"Search successful", data:out)
    end

    def self.enroll(attributes)
      data = attributes[:data]
      if attributes[:options] != nil
        tidas_id = attributes[:options][:tidas_id]
        overwrite = attributes[:options][:overwrite]
      end
      if overwrite && overwrite != true
        raise(ParameterError,"Overwrite may only be called as an enrollment option if the value is set to true")
      end

      Client.enroll(data, tidas_id, overwrite)
    end

    def self.validate(attributes)
      data      = attributes[:data]
      tidas_id  = attributes[:tidas_id]
      Client.validate(data, tidas_id)
    end

    def self.deactivate(attributes)
      tidas_id = attributes[:tidas_id]
      Client.deactivate(tidas_id)
    end

    def self.activate(attributes)
      tidas_id = attributes[:tidas_id]
      Client.activate(tidas_id)
    end

    def to_hash_with_key
      hash = to_hash
      hash[:public_key] = public_key
      hash
    end

    def to_hash
      {
        id: id,
        deactivated: deactivated,
        app: app_name
      }
    end

    private

    def initialize(attributes)
      @id = attributes[:id]
      @deactivated = attributes[:deactivated]
      @app_name = attributes[:app_name]
      @public_key = attributes[:public_key] || "<Filtered>"
    end

  end
end
