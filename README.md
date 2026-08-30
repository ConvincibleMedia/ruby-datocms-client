# DatoCMS Ruby Client

Maintained fork of the legacy DatoCMS Ruby client and CLI. It is intended for established projects that still use the original Ruby integration.

This fork is distributed from its Git repository. It is not published as an update to the existing `dato` gem, which remains controlled by its original owners.


## Installation

Reference the maintained repository directly from the consuming project's `Gemfile`:

```ruby
gem "dato", git: "https://github.com/ConvincibleMedia/ruby-datocms-client.git"
```

Run `bundle install` and retain the resulting commit revision in the consuming project's `Gemfile.lock`. A future RubyGems release may use a different package name such as `dato-legacy`, but no replacement package is currently published.


## API Client

This gem also exposes an API client, useful e.g. to import existing content in your DatoCMS administrative area. Read our [documentation](https://www.datocms.com/content-management-api/) for detailed info.


## Development

After checking out the repository, run `bin/setup` to install the locked dependencies. Run `bundle exec rake spec` for tests, `bundle exec rubocop` for style checks, and `bundle exec bundler-audit check --update` for dependency advisories. You can also run `bin/console` for an interactive prompt.

Build and smoke-test the package locally without publishing it:

```bash
bundle exec rake build
bash bin/smoke_package pkg/dato-*.gem
```

The `release` Rake task intentionally refuses to publish under the upstream `dato` name.


### Recording live API cassettes

Normal test runs replay the VCR cassettes committed under
`spec/fixtures/vcr_cassettes` and do not require DatoCMS credentials.

The asset-loading integration specs can be recorded against the live API with a dedicated persistent test account. The account must not have access to real projects or organizations, and must not use two-factor authentication. Each spec creates a disposable project, activates non-localized focal points, and deletes the project during teardown.

Run the Ruby recorder:

```bash
bundle exec ruby bin/record_asset_cassettes.rb
```

The script will read `DATOCMS_TEST_ACCOUNT_EMAIL` and `DATOCMS_TEST_ACCOUNT_PASSWORD` from `.env`.
