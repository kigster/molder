require 'yaml'
require 'hashie/mash'
require 'hashie/extensions/parsers/yaml_erb_parser'

module Molder
  class Configuration < Hashie::Mash
    DEFAULT_CONFIG = 'conf/molder.yml'.freeze
    class << self
      def default_config
        DEFAULT_CONFIG
      end

      def default
        load(default_config) if File.exist?(default_config)
      end
    end
  end
end
