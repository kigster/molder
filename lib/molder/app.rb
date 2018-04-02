require 'hashie/mash'
require 'hashie/extensions/mash/symbolize_keys'
require 'molder/errors'
require 'parallel'
require 'fileutils'
module Molder
  class App

    attr_accessor :config, :options, :command, :command_name, :commands, :templates, :log_dir

    def initialize(config:, options:, command_name:)
      self.config       = config
      self.options      = options
      self.command_name = command_name
      self.commands     = []
      self.log_dir      = options[:log_dir] || config.global.log_dir || './log'

      resolve_command!

      resolve_templates!
    end

    def execute!
        colors = %i(yellow blue red green magenta cyan white)

        FileUtils.mkdir_p(log_dir)
        puts "Executing #{commands.size} commands using a pool of up to #{options.max_processes} processes:\n".bold.cyan.underlined
        ::Parallel.each((1..commands.size),
                        :in_processes => options.max_processes) do |i|

          color = colors[(i - 1) % colors.size]
          cmd   = commands[i - 1]

          printf('%s', "Worker: #{Parallel.worker_number}, command #{i}\n".send(color)) if options.verbose
          puts "#{cmd}\n".send(color)

          system %Q(( #{cmd} ) > #{log_dir}/#{command_name}.#{i}.log) unless options.dry_run
      end
    end

    private

    def resolve_templates!
      self.templates ||= []
      options.names.each_pair do |name, indexes|
        if config.templates[name]
          template_array = config.templates[name].is_a?(Array) ?
                             config.templates[name] :
                             [config.templates[name]]

          template_array.flatten.each do |attrs|
            attributes = attrs.dup
            attributes.merge!(options.override) if options.override
            self.templates << ::Molder::Template.new(config:     config,
                                                     name:       name,
                                                     indexes:    indexes,
                                                     command:    command,
                                                     attributes: attributes)
          end
        else
          raise ::Molder::InvalidTemplateName, "Template name #{name} is not valid."
        end
      end

      self.templates.each do |t|
        t.each_command do |cmd|
          self.commands << cmd
        end
      end
    end

    def resolve_command!
      unless config.commands.include?(command_name)
        raise(::Molder::InvalidCommandError, "Command #{command_name} is not defined in the configuration file #{options[:config]}")
      end

      command_hash = Hashie::Extensions::SymbolizeKeys.symbolize_keys(config.commands[command_name].to_h)
      self.command = Molder::Command.new(name: command_name, config: config, **command_hash)
    end
  end
end
