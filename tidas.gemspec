# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tidas/version'

Gem::Specification.new do |gem|
  gem.name          = "tidas"
  gem.version       = Tidas::VERSION
  gem.summary       = %q{Rack middleware for tidas integrations}
  gem.description   = %q{Rack middleware for tidas integrations}
  gem.license       = "MIT"
  gem.authors       = ["Nick Esposito"]
  gem.email         = "nick.esposito@trailofbits.com"
  gem.homepage      = "https://github.com/trailofbits/tidas-ruby#readme"

  gem.files         = `git ls-files`.split($/)

  `git submodule --quiet foreach --recursive pwd`.split($/).each do |submodule|
    submodule.sub!("#{Dir.pwd}/",'')

    Dir.chdir(submodule) do
      `git ls-files`.split($/).map do |subpath|
        gem.files << File.join(submodule,subpath)
      end
    end
  end
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'faraday', '~> 0.9'

  gem.add_development_dependency 'bundler', '~> 1.10'
  gem.add_development_dependency 'rake', '~> 12.0'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'
  gem.add_development_dependency 'yard', '~> 0.9'
end
