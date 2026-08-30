# Dependency and API verification


## Outcome

The locked dependency set, legacy API discovery, live integration path and final offline workflow are working on Ruby 2.7.5. Available dependency movement beyond this baseline consists principally of breaking major releases or versions requiring newer Ruby.


## Dependency findings

* `bundle outdated --strict` reports the constrained bundle is current.
* An unconstrained audit identifies future major work including ActiveSupport 7.2 or later and Faraday 2. These are not safe baseline updates while Ruby 2.7 remains supported.
* Added Bundler Audit 0.9.3 to development dependencies and continuous integration.
* ActiveSupport 7.1.6 is nominally affected by CVE-2026-33169, CVE-2026-33170 and CVE-2026-33176. Patched supported releases require newer Ruby.
* The affected SafeBuffer and number-helper code is not used by this client. Replaced `active_support/all` with targeted Hash, Object and String extension requires, and added exact documented audit exceptions for those three low-severity advisories.
* Any new advisory still fails the automated audit. The exceptions must be removed when the Ruby 3.3 work permits a patched ActiveSupport branch.


## API findings

* The client continues to discover resources dynamically from the account and site API hyperschema documents.
* Both live hyperschema URLs returned successfully.
* The client sends `X-Api-Version: 3`, matching DatoCMS's current documented Content Management API version.
* The controlled recorder authenticated with the dedicated account and passed four live examples in 1 minute 23.73 seconds.
* Each example's disposable project teardown completed. The recorder's post-run validation found all four cassettes and found no account email, password or unredacted project token.


## Package findings

* Replaced the Git-derived package file list with a deterministic runtime-only list.
* The package now contains the licence, changelog, README, executable and Ruby library files; development scripts, CI configuration and live-test tooling are excluded.


## Final evidence

* `bundle check` — dependencies satisfied.
* `bundler-audit check --update` — no unhandled vulnerabilities.
* RuboCop — 127 files, no offences.
* RSpec — 155 examples, no failures, 93.64% line coverage.
* Package build — `pkg/dato-0.8.4.gem` produced successfully.
* Isolated consumer smoke test — 47 dependencies installed, `require "dato"` succeeded, and installed CLI help succeeded.


## Follow-up

* Add Ruby 3.3 to CI and complete the minimum-version change as a deliberate compatibility project.
* Upgrade ActiveSupport to a patched branch, remove the audit exceptions and revisit all Ruby 2.7 dependency ceilings during that project.
* Treat Faraday 2 as an explicit migration with request, middleware and error-handling tests.
* Keep repository distribution separate from any future decision to publish under a new name such as `dato-legacy`.


## Status

Complete.
