
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'molder/version'

module Molder
  DESCRIPTION = <<-eof
Molder is a command line tool for generating and running 
(in parallel) a set of related but similar commands. A key 
use-case is auto-generation of the host provisioning commands 
for an arbitrary cloud environment. The gem is not constrained 
to any particular cloud tool or even a command, and can be used 
to generate a consistent set of commands based on several customizable 
dimensions. For example, you could generate 600 provisioning commands
for hosts in EC2, numbered from 1 to 100, constrained to the 
dimensions "zone-id" (values: ["a", "b", "c"]) and the data center "dc" 
(values: ['us-west2', 'us-east1' ]).
  eof
end

Gem::Specification.new do |spec|
  spec.name          = 'molder'
  spec.version       = Molder::VERSION
  spec.authors       = ['Konstantin Gredeskoul']
  spec.email         = ['kigster@gmail.com']

  spec.summary       = Molder::DESCRIPTION
  spec.description   = Molder::DESCRIPTION
  spec.homepage      = 'https://github.com/kigster/molder'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'liquid'
  spec.add_dependency 'hashie'
  spec.add_dependency 'colored2'
  spec.add_dependency 'parallel'
  spec.add_dependency 'dry-configurable'
  spec.add_dependency 'require_dir', '~> 2'

  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'aruba'
  spec.add_development_dependency 'aruba-doubles'
end
