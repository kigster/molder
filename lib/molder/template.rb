require 'molder/renderer'
module Molder
  class Template
    attr_accessor :config, :name, :attributes, :indexes, :command

    def initialize(config:, name:, indexes:, attributes: {}, command:)
      self.config     = config
      self.name       = name
      self.indexes    = indexes
      self.command    = command
      self.attributes = normalize(attributes)
    end

    def each_command
      indexes.map do |i|
        self.attributes[:number] = i
        self.attributes[:formatted_number] = sprintf(config.global.index_format, i)
        ::Molder::Renderer.new(command.args).render(attributes.dup).tap do |cmd|
          yield(cmd.gsub(/\n/, ' ').gsub(/\s{2,}/, ' ')) if block_given?
        end
      end
    end

    def normalize(attrs)
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
