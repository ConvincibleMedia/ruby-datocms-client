<!--datocms-autoinclude-header start-->
<a href="https://www.datocms.com/"><img src="https://www.datocms.com/images/full_logo.svg" height="60"></a>

👉 [Visit the DatoCMS homepage](https://www.datocms.com) or see [What is DatoCMS?](#what-is-datocms)
<!--datocms-autoinclude-header end-->

# DatoCMS Ruby Client

[![Coverage Status](https://coveralls.io/repos/github/datocms/ruby-datocms-client/badge.svg?branch=master)](https://coveralls.io/github/datocms/ruby-datocms-client?branch=master) [![Build Status](https://travis-ci.org/datocms/ruby-datocms-client.svg?branch=master)](https://travis-ci.org/datocms/ruby-datocms-client) [![Gem Version](https://badge.fury.io/rb/dato.svg)](https://badge.fury.io/rb/dato)

CLI tool for DatoCMS (https://www.datocms.com).

## How to integrate DatoCMS with Jekyll

Please head over the [Jekyll section of our documentation](https://www.datocms.com/docs/jekyll/) to learn everything you need to get started.

## How to integrate DatoCMS with Middleman

For Middleman we have created a nice Middleman extension called [middleman-dato](https://github.com/datocms/middleman-dato). Please visit the [Middleman section of our documentation](https://docs.datocms.com/middleman/overview.html) to learn everything you need to get started.

## API Client

This gem also exposes an API client, useful ie. to import existing content in your DatoCMS administrative area. Read our [documentation](https://www.datocms.com/content-management-api/) for detailed info.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

### Recording live API cassettes

Normal test runs replay the VCR cassettes committed under
`spec/fixtures/vcr_cassettes` and do not require DatoCMS credentials.

The asset-loading integration specs can be recorded against the live API with a dedicated persistent test account. The account must not have access to real projects or organizations, and must not use two-factor authentication. Each spec creates a disposable project, activates non-localized focal points, and deletes the project during teardown.

Copy the ignored `.env` template and add the dedicated test-account credentials:

```bash
cp .env.example .env
```

From WSL, run the Ruby recorder:

```bash
bundle exec ruby bin/record_asset_cassettes.rb
```

The script reads `DATOCMS_TEST_ACCOUNT_EMAIL` and `DATOCMS_TEST_ACCOUNT_PASSWORD` from `.env`. Existing process environment variables take priority; missing values are requested interactively, with password input hidden.

The script backs up and removes the four target cassettes before enabling VCR's `:all` mode for its RSpec child process. It restores those backups if RSpec fails or if the resulting cassettes contain the supplied email or password. Credentials, session IDs, authorization headers, and project API tokens are replaced with playback-only placeholders before the cassettes are written.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/datocms/ruby-datocms-client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


<!--datocms-autoinclude-footer start-->
-----------------
# What is DatoCMS?
<a href="https://www.datocms.com/"><img src="https://www.datocms.com/images/full_logo.svg" height="60"></a>

[DatoCMS](https://www.datocms.com/) is the REST & GraphQL Headless CMS for the modern web.

Trusted by over 25,000 enterprise businesses, agency partners, and individuals across the world, DatoCMS users create online content at scale from a central hub and distribute it via API. We ❤️ our [developers](https://www.datocms.com/team/best-cms-for-developers), [content editors](https://www.datocms.com/team/content-creators) and [marketers](https://www.datocms.com/team/cms-digital-marketing)!

**Quick links:**

- ⚡️ Get started with a [free DatoCMS account](https://dashboard.datocms.com/signup)
- 🔖 Go through the [docs](https://www.datocms.com/docs)
- ⚙️ Get [support from us and the community](https://community.datocms.com/)
- 🆕 Stay up to date on new features and fixes on the [changelog](https://www.datocms.com/product-updates)

**Our featured repos:**
- [datocms/react-datocms](https://github.com/datocms/react-datocms): React helper components for images, Structured Text rendering, and more
- [datocms/js-rest-api-clients](https://github.com/datocms/js-rest-api-clients): Node and browser JavaScript clients for updating and administering your content. For frontend fetches, we recommend using our [GraphQL Content Delivery API](https://www.datocms.com/docs/content-delivery-api) instead.
- [datocms/cli](https://github.com/datocms/cli): Command-line interface that includes our [Contentful importer](https://github.com/datocms/cli/tree/main/packages/cli-plugin-contentful) and [Wordpress importer](https://github.com/datocms/cli/tree/main/packages/cli-plugin-wordpress)
- [datocms/plugins](https://github.com/datocms/plugins): Example plugins we've made that extend the editor/admin dashboard
- [datocms/gatsby-source-datocms](https://github.com/datocms/gatsby-source-datocms): Our Gatsby source plugin to pull data from DatoCMS
- Frontend examples in different frameworks: [Next.js](https://github.com/datocms/nextjs-demo), [Vue](https://github.com/datocms/vue-datocms) and [Nuxt](https://github.com/datocms/nuxtjs-demo), [Svelte](https://github.com/datocms/datocms-svelte) and [SvelteKit](https://github.com/datocms/sveltekit-demo), [Astro](https://github.com/datocms/datocms-astro-blog-demo), [Remix](https://github.com/datocms/remix-example). See [all our starter templates](https://www.datocms.com/marketplace/starters).

Or see [all our public repos](https://github.com/orgs/datocms/repositories?q=&type=public&language=&sort=stargazers)
<!--datocms-autoinclude-footer end-->
