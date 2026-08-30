# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dato/version'

Gem::Specification.new do |spec|
  spec.name          = 'dato'
  spec.version       = Dato::VERSION
  spec.authors       = ['Convincible', 'Stefano Verna']
  spec.email         = ['development@convincible.media']

  spec.summary       = 'Maintained legacy Ruby client for the DatoCMS API'
  spec.description   = 'Repository-distributed maintained fork of the legacy DatoCMS Ruby client'
  spec.homepage      = 'https://github.com/ConvincibleMedia/ruby-datocms-client'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7.5'
  spec.metadata      = {
    'source_code_uri' => spec.homepage,
    'changelog_uri' => "#{spec.homepage}/blob/main/changelog.md",
  }

  spec.files         = Dir.glob([
                                  'LICENSE.txt',
                                  'changelog.md',
                                  'readme.md',
                                  'exe/dato',
                                  'lib/**/*.rb',
                                ])
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'bundler-audit', '~> 0.9'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubyzip'
  spec.add_development_dependency 'simplecov', '~> 0.17.0'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'front_matter_parser'

  spec.add_runtime_dependency 'faraday', ['>= 0.9.0']
  spec.add_runtime_dependency 'faraday_middleware', ['>= 0.9.0']
  # Active Support 7.2+ requires Ruby 3.1.
  spec.add_runtime_dependency 'activesupport', ['>= 4.2.7', '< 7.2']
  # SecureRandom 0.4 requires Ruby 3.1 and is resolved by Active Support.
  spec.add_runtime_dependency 'securerandom', ['< 0.4']
  # Minitest 5.26.2+ requires Ruby 3.1 and is resolved by Active Support.
  spec.add_runtime_dependency 'minitest', ['<= 5.26.1']
  # Connection Pool 3 requires Ruby 3.2 and is resolved by Active Support.
  spec.add_runtime_dependency 'connection_pool', ['< 3']
  # I18n 1.15 requires Ruby 3.1 and is resolved by Active Support.
  spec.add_runtime_dependency 'i18n', ['< 1.15']
  spec.add_runtime_dependency 'addressable'
  # Public Suffix 6 requires Ruby 3 and is resolved transitively by Addressable.
  spec.add_runtime_dependency 'public_suffix', ['< 6']
  spec.add_runtime_dependency 'thor'
  spec.add_runtime_dependency 'imgix', ['~> 4']
  spec.add_runtime_dependency 'toml'
  spec.add_runtime_dependency 'cacert'
  # Dotenv 3 requires Ruby 3.
  spec.add_runtime_dependency 'dotenv', ['< 3']
  spec.add_runtime_dependency 'pusher-client'
  spec.add_runtime_dependency 'listen'
  # FFI 1.17 platform gems require newer Ruby or RubyGems than Ruby 2.7 ships.
  spec.add_runtime_dependency 'ffi', ['< 1.17']
  spec.add_runtime_dependency 'dato_json_schema'
  spec.add_runtime_dependency 'mime-types'
end
