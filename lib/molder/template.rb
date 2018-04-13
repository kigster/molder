require 'molder/renderer'
module Molder
  class Template
    attr_accessor :config, :name, :attributes, :indexes, :command, :options

    def initialize(config:, name:, indexes:, attributes: {}, command:, options: {})
      self.config     = config
      self.name       = name
      self.indexes    = indexes
      self.command    = command
      self.options    = options
      self.attributes = self.class.normalize(attributes)
    end

    def each_command
      indexes.map do |i|
        self.attributes[:number] = i
        self.attributes[:formatted_number] = sprintf(config.global.index_format, i)
        ::Molder::Renderer.new(command.args, options).render(attributes.dup).tap do |cmd|
          yield(cmd) if block_given?
        end
      end
    end

    def self.normalize(attrs)
      override = {}
      attrs.each_pair do |key, value|
        if value.is_a?(Hash) && value.values.compact.empty?
          override[key] = value.keys.to_a.join(',')
        end
      end
      attrs.merge!(override)
    end

  end
end
