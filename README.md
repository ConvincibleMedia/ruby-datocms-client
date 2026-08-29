# DatoCMS Ruby Client

CLI tool for DatoCMS (https://www.datocms.com).


## API Client

This gem also exposes an API client, useful e.g. to import existing content in your DatoCMS administrative area. Read our [documentation](https://www.datocms.com/content-management-api/) for detailed info.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.


### Recording live API cassettes

Normal test runs replay the VCR cassettes committed under
`spec/fixtures/vcr_cassettes` and do not require DatoCMS credentials.

The asset-loading integration specs can be recorded against the live API with a dedicated persistent test account. The account must not have access to real projects or organizations, and must not use two-factor authentication. Each spec creates a disposable project, activates non-localized focal points, and deletes the project during teardown.

Run the Ruby recorder:

```bash
bundle exec ruby bin/record_asset_cassettes.rb
```

The script will read `DATOCMS_TEST_ACCOUNT_EMAIL` and `DATOCMS_TEST_ACCOUNT_PASSWORD` from `.env`.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).