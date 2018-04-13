require 'hashie/mash'
require 'colored2'
require 'optionparser'

require 'etc'

module Molder
  class CLI
    attr_accessor :argv, :original_argv, :options, :config, :command
    attr_reader :stdout, :stdin, :stderr, :kernel

    class << self
      attr_accessor :instance
    end

    def initialize(argv, stdin = STDIN, stdout = STDOUT, stderr = STDERR, kernel = Kernel)
      @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel

      self.options                 = Hashie::Mash.new
      self.options[:max_processes] = Etc.nprocessors - 2
      self.argv                    = argv.dup
      self.original_argv           = argv.dup
      self.class.instance          = self
    end

    def execute!

      self.argv << '-h' if argv.empty?

      parser.parse!(self.argv)

      if options.help
        @kernel.exit(0)
        return
      end

      exit_code = begin
        $stderr = @stderr
        $stdin  = @stdin
        $stdout = @stdout

        parse_args!

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

    def parse_args!
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
      OptionParser.new(nil, 35) do |opts|
        opts.separator 'OPTIONS:'.bold.yellow

        opts.on('-c', '--config [file]',
                'Main YAML configuration file') { |config| options[:config] = config }

        opts.on('-t', '--template [n1/n2/..]',
                'Names of the templates to use') do |value|
          options[:names] ||= Hashie::Mash.new
          value.split('/').each { |arg| parse_templates(arg) }
        end

        opts.on('-i', '--index [range/array]',
                'Numbers to use in generating commands',
                'Can be a comma-separated list of values,',
                'or a range, eg "1..5"') do |value|
          options[:indexes] = index_expression_to_array(value)
        end

        opts.on('-a', '--attrs [k1=v1/k2=v2/...]',
                'Provide additional attributes, or override existing ones') do |value|
          h = {}
          value.split('/').each do |pair|
            key, value = pair.split('=')
            h[key]     = value
          end
          options[:override] = h
        end

        opts.on('-m', '--max-processes [number]',
                'Do not start more than this many processes at once') { |value| options[:max_processes] = value.to_i }

        opts.on('-l', '--log-dir [dir]',
                'Directory where STDOUT of running commands is saved') { |value| options[:log_dir] = value }

        opts.on('-n', '--dry-run',
                'Don\'t actually run commands, just print them') { |_value| options[:dry_run] = true }

        opts.on('-v', '--verbose',
                'Print more output') { |_value| options[:verbose] = true }

        opts.on('-b', '--backtrace',
                'Show error stack trace if available') { |_value| options[:backtrace] = true }

        opts.on('-h', '--help',
                'Show help') do
          @stdout.puts opts
          options[:help] = true
        end

      end.tap do |p|
        p.banner = <<-eof
#{'DESCRIPTION'.bold.yellow}
    Molder is a template based command generator and runner for cases where you need to 
    generate many similar and yet somewhat different commands, defined in the 
    YAML template. Please read #{'https://github.com/kigster/molder'.bold.blue.underlined} for 
    a detailed explanation of the config file structure.

    Note that the default configuration file is #{Molder::Configuration::DEFAULT_CONFIG.bold.green}. 

#{'USAGE'.bold.yellow}
        #{'molder [-c config.yml] command template1[n1..n2]/template2[n1,n2,..]/...  [options]'.bold.blue}
        #{'molder [-c config.yml] command -t template -i index [options]'.blue.bold}

        #{'EXAMPLES'.bold.yellow}
        #{'# The following commands assume YAML file is in the default location:'.bold.black}
        #{'molder provision web[1,3,5]'.bold.blue}

        #{'# -n flag means dry run — so instead of running commands, just print them:'.bold.black}
        #{'molder provision web[1..4]/job[1..4] -n'.bold.blue}

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

