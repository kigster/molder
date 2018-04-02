# Molder

Molder is a command line tool for generating and running (in parallel) a set of related but similar commands. A key
use-case is auto-generation of the host provisioning commands for an arbitrary cloud environment. The gem is not constrained to any particular cloud tool or even a command, and can be used to generate a consistent set of commands based on several customizable dimensions.

For example, you could generate 600 provisioning commands for hosts in EC2, numbered from 1 to 100, constrained to the dimensions "zone-id" (values: ["a", "b", "c"]) and the data center "dc" (values: ['us-west2', 'us-east1' ]).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'molder'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install molder

## Usage


```bash
DESCRIPTION
    Molder is a template based command generator for cases where you need
    generate many similar and yet somewhat different commands.

USAGE
    molder [-c config/molder.yml] [options]
    molder command name1[n1..n2]/name2[n1,n2,..]/... [-c config/molder.yml] [options]

EXAMPLES
    molder -c config/molder.yml web[1,3,5]/sidekiq[3..5]
    molder -c config/molder.yml -n web/sidekiq -i 1..5

OPTIONS:
    -c, --config [file]              Main YAML configuration file
        --name [n1/n2/..]            Names of the templates to use
    -i, --index [range/array]        Numbers to use in generating commands
                                     Can be a comma-separated list of values,
                                     or a range, eg "1..5"
    -o, --override [k1=v1/k2=v2/..]  Override values in the config
    -m, --max-processes [number]     Do not start more than this many processes at once
    -l, --log-dir [dir]              Directory where STDOUT of running commands is save
    -n, --dry-run                    Don't actually run commands, just print them
    -b, --backtrace                  Show error stack trace if available
    -h, --help                       Show help
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kigster/molder.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
