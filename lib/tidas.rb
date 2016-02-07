require 'tidas/utilities'
require 'tidas/utilities/unpacker'
require 'tidas/utilities/response_packager'

require 'tidas/version'
require 'tidas/configuration'

require 'tidas/client'
require 'tidas/error_result'
require 'tidas/identity'
require 'tidas/successful_result'

require 'json'
require 'faraday'

module Tidas
  def self.ping
    Client.ping
  end
end
