# Dual-runtime continuous integration


## Goals

* Parameterise hosted verification across Ruby 2.7.5 and Ruby 3.3.
* Keep dependency auditing, RuboCop, the offline suite, package construction and installed-package smoke testing on both runtimes.
* Retain Ruby 2.7.5 as the documented development baseline and minimum supported version.


## Completion criteria

* The workflow defines independent Ruby 2.7.5 and Ruby 3.3 verification jobs.
* Both jobs exercise the complete existing verification sequence.
* Hosted CI passes on both runtimes without changing the gem's minimum Ruby requirement.


## Completed work

* Converted the existing `verify` job to a Ruby-version matrix containing Ruby 2.7.5 and Ruby 3.3.
* Kept dependency auditing, RuboCop, the offline suite, package construction and installed-package smoke testing in the shared job steps, so both runtimes execute the complete sequence.
* Disabled matrix fail-fast to preserve diagnostic output from both runtimes when either fails.
* Confirmed statically that `.ruby-version` remains 2.7.5 and `required_ruby_version` remains `>= 2.7.5`.
* Completed the full local verification sequence under Ruby 2.7.5 and Ruby 3.3.6 with the lockfile's Bundler 2.4.14.


## Local evidence

* Dependency installation completed on both runtimes.
* The updated advisory database reported no vulnerabilities on either runtime.
* RuboCop inspected 127 files without offences on both runtimes.
* The offline suite passed 155 examples with no failures and 93.64% line coverage on both runtimes.
* `dato-0.8.4.gem` built successfully on both runtimes.
* Fresh isolated package installation, `require "dato"`, version reporting and installed CLI help passed on both runtimes.


## Remaining work

* Commit and push the workflow change, then confirm both hosted matrix jobs pass.


## Next action

Commit and push the workflow change, then verify both matrix jobs in GitHub Actions. Fix any hosted-only failure without changing the Ruby 2.7.5 compatibility floor.
