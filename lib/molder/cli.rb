require 'hashie/mash'
require 'colored2'
require 'optionparser'

require 'etc'

module Molder
  class CLI
    attr_accessor :argv, :original_argv, :options, :config, :command

    def initialize(argv, stdin = STDIN, stdout = STDOUT, stderr = STDERR, kernel = Kernel)
      @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel

      self.options                 = Hashie::Mash.new
      self.options[:max_processes] = Etc.nprocessors - 2
      self.argv                    = argv.dup
      self.original_argv           = argv.dup

      self.argv << '-h' if argv.empty?

      parser.parse!(self.argv)

      pre_parse!

      if options.indexes
        override = {}
        options.names.each_pair do |name, values|
          if values.nil?
            override[name] = option.indexes
          end
        end
        options.names.merge!(override)
      end

      self.config = if options.config
                      if File.exist?(options.config)
                        Configuration.load(options.config)
                      else
                        report_error(message: "file #{options.config} does not exist.")
                      end
                    else
                      Configuration.default
                    end
    end

    def execute!
      exit(0) if options.help

      exit_code = begin
        $stderr = @stderr
        $stdin  = @stdin
        $stdout = @stdout

        App.new(config: config, options: options, command_name: command).execute!
        0
      rescue StandardError => e
        report_error(exception: e)
        1
      rescue SystemExit => e
        e.status
      ensure
        $stderr = STDERR
        $stdin  = STDIN
        $stdout = STDOUT
      end
      @kernel.exit(exit_code)
    end

    private

    def pre_parse!
      if argv[0] && !argv[0].start_with?('-')
        self.command = argv.shift
      end

      if self.argv[0] && !self.argv[0].start_with?('-')
        options[:names] = Hashie::Mash.new
        self.argv.shift.split('/').each { |arg| parse_templates(arg) }
      end
    end

    def parser
      OptionParser.new do |opts|
        opts.separator 'OPTIONS:'.bold.blue
        opts.on('-c', '--config [file]', 'Main YAML configuration file') do |config|
          options[:config] = config
        end
        opts.on('-n', '--name [n1/n2/..]', 'Names of the templates to use') do |value|
          options[:names] ||= Hashie::Mash.new
          value.split('/').each { |arg| parse_templates(arg) }
        end
        opts.on('-i', '--index [range/array]', 'Numbers to use in generating commands',
                'Can be a comma-separated list of values,', 'or a range, eg "1..5"') do |value|
          options[:indexes] = index_expression_to_array(value)
        end
        opts.on('-o', '--override [k1=v1/k2=v2/..]', 'Override values in the config') do |value|
          h = {}
          value.split('/').each do |pair|
            key, value = pair.split('=')
            h[key]     = value
          end
          options[:override] = h
        end
        opts.on('-m', '--max-processes [number]', 'Do not start more than this many processes at once') do |value|
          options[:max_processes] = value.to_i
        end
        opts.on('-l', '--log-dir [dir]', 'Directory where STDOUT of running commands is saved') do |value|
          options[:log_dir] = value
        end
        opts.on('-n', '--dry-run', 'Don\'t actually run commands, just print them') do |_value|
          options[:dry_run] = true
        end
        opts.on('-b', '--backtrace', 'Show error stack trace if available') do |_value|
          options[:backtrace] = true
        end
        opts.on('-h', '--help', 'Show help') do
          @stdout.puts opts
          options[:help] = true
        end
      end.tap do |p|
        p.banner = <<-eof
#{'DESCRIPTION'.bold.blue}
    Molder is a template based command generator for cases where you need
    generate many similar and yet somewhat different commands.

#{'USAGE'.bold.blue}
    molder [-c config/molder.yml] [options]
    molder command name1[n1..n2]/name2[n1,n2,..]/... [-c config/molder.yml] [options] 

#{'EXAMPLES'.bold.blue}
    molder -c config/molder.yml web[1,3,5]/sidekiq[3..5]
    molder -c config/molder.yml -n web/sidekiq -i 1..5

        eof
      end
    end

    def report_error(message: nil, exception: nil)
      if options[:backtrace] && exception.backtrace
        @stderr.puts exception.backtrace.reverse.join("\n").yellow.italic
      end
      @stderr.puts "Error: #{exception.to_s.bold.red}" if exception
      @stderr.puts "Error: #{message.bold.red}" if message
      @kernel.exit(1)
    end

    def parse_templates(arg)
      options[:names] ||= Hashie::Mash.new
      templates       = arg.split('/')
      templates.each do |t|
        name, indexes         = parse_name(t)
        options[:names][name] = indexes
      end
    end

    def parse_name(t)
      name, values = t.split('[')
      values.gsub!(/\]/, '') if values
      [name, index_expression_to_array(values)]
    end

    def index_expression_to_array(value = nil)
      return nil if value.nil?
      value.include?('..') ? eval("(#{value}).to_a") : eval("[#{value}]")
    end
  end
end

