require 'base64'
require 'digest'

module Tidas
  module Utilities
    class Unpacker

      attr_accessor :parsed_data

      def self.init_with_blob(blob)
        Utilities::Unpacker.new( {blob: blob} )
      end

      def parse
        pull_val_from_data(data_str)
        @parsed_data
      end

      def data_str
        Base64.decode64(@blob)
      end

      def to_s
        @blob
      end

      def raw_blob_stripped_of_data
        data_str.sub(data_bytes, '')
      end

      def blob_stripped_of_data
        Base64.encode64(raw_blob_stripped_of_data)
      end

      private

      def initialize(attributes)
        @blob = attributes[:blob]
        @parsed_data = {}
        parse
        raise StandardError, "Malformed Data Object" unless valid?
      end

      def pull_val_from_data(data)
        return unless data[0]
        type_char = data[0].unpack('C')[0]
        type_str  = Utilities::SERIALIZATION_FIELDS[type_char]
        field_len = data[1..4].unpack('I')[0]

        val_end = 5+field_len-1
        raw_val = data[5..val_end] 

        val = extract_val(type_str, raw_val)

        @parsed_data[type_str] = val

        shorter_data = data[val_end+1..-1]
        if shorter_data && shorter_data.length > 0
          pull_val_from_data(shorter_data)
        end
      end

      def extract_val(type, raw_val)
        if type == :platform
          raw_val.unpack('C')[0]
        elsif type == :timestamp
          time_data = raw_val.unpack('I')[0]
          Time.at(time_data)
        else
          raw_val.unpack('C*').map{|e| e.chr }.join
        end
      end

      def data_bytes
        data_to_sign  = @parsed_data[:data_to_sign] || String.new
        #identifier
        type_byte     = [1].pack("C")
        #datalen
        len_bytes     = [data_to_sign.length].pack("L")

        type_byte + len_bytes + data_to_sign
      end

      def timestamp_hex
        begin
          epoch_time = @parsed_data[:timestamp].to_i
          return [epoch_time].pack('q<')
        rescue
          return []
        end
      end

      def computed_hash_bytes
        Digest::SHA1.digest(@parsed_data[:data_to_sign]+timestamp_hex).bytes
      end

      def provided_hash_bytes
        @parsed_data[:data_hash].bytes
      end

      def data_matches_hash?
        begin
          return computed_hash_bytes == provided_hash_bytes
        rescue
          return false
        end
      end

      def valid?
        return false if @parsed_data[:platform]   == nil
        return false if @parsed_data[:timestamp]  == nil
        return false if @parsed_data[:data_hash]  == nil
        return false if @parsed_data[:signature]  == nil
        return false unless data_matches_hash?
        true
      end

    end
  end
end
