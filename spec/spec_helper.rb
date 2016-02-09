if ENV['CODECLIMATE_REPO_TOKEN']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require 'rspec'
require 'tidas/version'

require 'simplecov'
SimpleCov.start

include Tidas
