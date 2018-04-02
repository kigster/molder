lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'molder/version'

Gem::Specification.new do |spec|
  spec.name          = 'molder'
  spec.version       = ::Molder::VERSION
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
  spec.add_dependency 'require_dir', '~> 2'

  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'rspec-its'
end
