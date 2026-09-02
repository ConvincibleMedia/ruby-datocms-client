# Development continuation

Continue development from the restored maintenance baseline while retaining Ruby 2.7.5 as the minimum supported version.


## Status

Planned. This document is a hand-off only; no implementation work described below has started.


## Constraints and decisions

* Ruby 2.7.5 remains the compatibility floor and the required legacy CI gate.
* Ruby 3.3 coverage will verify forward compatibility; it will not change `required_ruby_version` or remove Ruby 2.7.5 support.
* Distribution remains by direct Git repository reference.
* Do not create a Git release tag as part of this plan.
* Do not publish the existing `dato` gem. Any future RubyGems package under another name is separate work.
* Keep the current Ruby 2.7 dependency ceilings and ActiveSupport audit exceptions until a deliberate minimum-version upgrade.
* Run project commands through interactive WSL Bash from `~/cm/ruby-datocms-client`.


## Planned stages

### 1. Dual-runtime continuous integration

Add Ruby 3.3 to the hosted CI matrix while retaining Ruby 2.7.5.

Work:

* Parameterise the existing verification job for Ruby 2.7.5 and Ruby 3.3.
* Run dependency installation, RuboCop, the full offline suite, package construction and package smoke testing on both runtimes unless duplication proves materially problematic.
* Preserve the existing dependency audit and the `vendor/bundle` RuboCop exclusion.
* Do not alter the gem's minimum Ruby requirement.

Completion criteria:

* Both Ruby jobs pass in hosted CI.
* Ruby 2.7.5 remains declared in `.ruby-version`, the gemspec and documentation as the development and compatibility baseline.
* Any Ruby 3.3-only failure is fixed without breaking the Ruby 2.7.5 job.


### 2. Git-source consumer smoke test

Add a minimal consumer test for the repository-reference installation path that users actually rely on.

Work:

* Create a temporary consumer project with a Gemfile referencing this repository as a Git source at an explicit revision.
* Install into an isolated bundle location rather than reusing the development bundle.
* Require `dato`, report `Dato::VERSION`, and run basic installed CLI help.
* Keep the existing built-package smoke test; the two checks cover different installation paths.
* Ensure temporary files and dependency caches cannot enter the built package or RuboCop target set.

Completion criteria:

* The consumer resolves the gem from Git and locks an explicit repository revision.
* Library loading and CLI startup pass on Ruby 2.7.5 and Ruby 3.3.
* Failure output clearly distinguishes dependency resolution, library loading and CLI failures.


### 3. Current DatoCMS coverage audit

Map the maintained client against the current DatoCMS APIs before selecting feature work.

Work:

* Inventory account and site hyperschema resources exposed through the dynamic API client.
* Inventory field types and transformations supported by the local loader, item repository, dump formats and utility classes.
* Review the CLI commands and options against current API behaviour.
* Separate generic schema-driven support from code paths that require explicit Ruby implementations.
* Identify missing support, stale assumptions and weak or cassette-only coverage.
* Use the dedicated disposable-project test account only for focused live verification after the read-only comparison is complete.
* Record each finding with evidence, user impact, suggested tests and a priority.

Completion criteria:

* A durable coverage report maps supported, partially supported and unsupported behaviour.
* Findings are prioritised rather than fixed during the audit.
* The first general-development issue can be selected from the report without repeating discovery.


### 4. First general-development change

Begin feature or defect work only after the first three stages are complete.

Work:

* Select one bounded, user-relevant issue from the coverage report or an existing project requirement.
* Add a regression or acceptance test before changing behaviour.
* Preserve Ruby 2.7.5 compatibility and verify Ruby 3.3.
* Regenerate VCR cassettes only when the behaviour genuinely requires live API evidence.
* Update the changelog and hand-off notes with the externally visible result.

Completion criteria:

* The selected behaviour is specified by tests and implemented without unrelated modernisation.
* Both CI runtimes and the consumer smoke test pass.
* Any follow-up work is recorded separately.


## Deferred work

The following is intentionally outside this continuation plan:

* Raising the minimum Ruby version.
* Removing Ruby 2.7.5 from CI.
* ActiveSupport, Faraday or other major dependency migrations.
* Removing the documented ActiveSupport advisory exceptions before a compatible patched version is available.
* Choosing or publishing a replacement RubyGems package such as `dato-legacy`.
* Creating a Git tag.


## Handoff starting point

The next developer should begin with stage 1 and confirm the current Ruby 2.7.5 job remains green before introducing the Ruby 3.3 matrix entry. No code changes for this plan have been attempted in this hand-off.
