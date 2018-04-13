require 'spec_helper'
require 'aruba/rspec'
require 'aruba/in_process'
require 'molder/cli'

module Molder
  PROJECT_ROOT = File.expand_path('../../', __FILE__)
end

RSpec.configure do |config|
  config.include Aruba::Api
end

# Some state gets fucked, and tests fail when run this way.

Aruba.configure do |config|
  config.command_launcher = :in_process
  config.main_class       = ::Molder::CLI
end
