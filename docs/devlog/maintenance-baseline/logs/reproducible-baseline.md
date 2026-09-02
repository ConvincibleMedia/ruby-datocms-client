# Reproducible baseline


## Goals

* Verify tests, gem building, isolated installation, library loading and CLI startup on Ruby 2.7.5.
* Make dependency resolution reproducible for maintainers.
* Declare the actual Ruby compatibility floor in gem metadata.
* Add Linux CI for linting, tests and package smoke checks.


## Completion criteria

Complete locally and in hosted CI.

* Ruby 2.7.5 with Bundler 2.4.14 satisfies the retained lockfile.
* RuboCop inspected 127 files without offences.
* The offline suite passed 155 examples with 93.64% line coverage.
* `dato-0.8.4.gem` built successfully and installed with 47 freshly resolved runtime gems under RubyGems 3.1.6.
* The isolated package supported `require "dato"` and displayed installed CLI help.
* CI mirrors lint, tests, build and package smoke checks on Ruby 2.7.5.


## Material findings

* Fresh Ruby 2.7 installs required explicit compatibility ceilings for Active Support, Dotenv, FFI, Public Suffix, SecureRandom, Minitest, Connection Pool and I18n.
* `bin/smoke_package` preserves the consumer-resolution check locally and in CI.
* The initial hosted run failed during RuboCop because `ruby/setup-ruby` cached dependencies inside `vendor/bundle`, exposing obsolete RuboCop configuration shipped by `rest-client`.
* `.rubocop.yml` now excludes `vendor/bundle/**/*`. Local RuboCop verification remains green at 127 project files and no offences, and the corrected hosted workflow passed.
