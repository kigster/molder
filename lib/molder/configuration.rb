require 'yaml'
require 'hashie/mash'
require 'hashie/extensions/parsers/yaml_erb_parser'

module Molder
  class Configuration < Hashie::Mash
    DEFAULT_CONFIG = 'config/molder.yml'.freeze
    class << self
      def default_config
        DEFAULT_CONFIG
      end

      def default
        if File.exist?(default_config)
          load(default_config)
        else
          raise ::Molder::ConfigNotFound, "Default file #{default_config} was not found"
        end

      end

      def load(file)
        self.new(YAML.load(File.read(file)))
      end
    end
  end
end
