module Tidas
  module Configuration

    attr_reader :server, :api_key, :application, :timeout

    def self.test_configure #:nodoc#
      Configuration.configure(
        server: 'http://localhost:3000',
        api_key: 'test-api-key',
        application: 'Javelin',
        timeout: 1
      )
    end

    def self.configure(attributes={})
      server = attributes.fetch(:server,ENV['tidas_server'])
      api_key = attributes.fetch(:api_key,ENV['tidas_api_key'])
      application = attributes.fetch(:application,ENV['tidas_application'])
      timeout = attributes.fetch(:timeout,ENV['tidas_timeout'])

      if server
        @server = server
      end

      if api_key
        @api_key = api_key
      end

      if application
        @application = application
      end

      if timeout
        @timeout = timeout.to_s
      end
    end

    def self.clear_configuration(flag)
      case flag
        when :server then @server = nil
        when :api_key then @api_key = nil
        when :application then @application = nil
        when :timeout then @timeout = nil
      end
    end

    def self.server
      @server
    end

    def self.api_key
      @api_key
    end

    def self.application
      @application
    end

    def self.timeout
      if timeout = @timeout
        timeout.to_i
      else
        20
      end
    end
  end
end
