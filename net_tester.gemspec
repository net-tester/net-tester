# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'net_tester/version'

Gem::Specification.new do |gem|
  gem.name = 'net_tester'
  gem.version = NetTester::VERSION
  gem.summary = "The poorman's IXIA."
  gem.description = 'Acceptance test framework for legacy (non-SDN) networks.'

  gem.licenses = %w(GPLv3 MIT)

  gem.authors = ['Yasuhito Takamiya']
  gem.email = ['yasuhito@gmail.com']
  gem.homepage = 'http://github.com/yasuhito/net_tester'

  gem.executables = %w(net_tester)
  gem.files = %w(Rakefile net_tester.gemspec)
  gem.files += Dir.glob('lib/**/*.rb')

  gem.require_paths = ['lib']

  gem.extra_rdoc_files = %w(README.md CHANGELOG.md)
  gem.test_files = Dir.glob('spec/**/*')
  gem.test_files += Dir.glob('features/**/*')

  gem.required_ruby_version = '>= 2.2.0'

  gem.add_dependency 'faker', '~> 1.6', '>= 1.6'
  gem.add_dependency 'gli', '= 2.13.4'
  gem.add_dependency 'pio', '~> 0.30.0'
end
