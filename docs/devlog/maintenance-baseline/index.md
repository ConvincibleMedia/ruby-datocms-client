# Maintenance baseline

Establish a reproducible, continuously verified Ruby 2.7.5 baseline from which maintenance and new development can proceed.


## Stages

* Reproducible baseline — complete locally; hosted CI confirmation pending.
* Repository distribution — complete.
* Dependency and API verification — complete.


## Key decisions and findings

* Ruby 2.7.5 remains the supported development and compatibility baseline for now. Raising the minimum to Ruby 3.3 is deferred.
* The maintained fork is distributed by direct Git repository reference. It cannot publish updates to the existing `dato` gem.
* A future RubyGems release may use another name such as `dato-legacy`, but no new package name is selected in this work.
* Development commands run in interactive WSL Bash from `~/cm/ruby-datocms-client`.
* The existing offline suite passes on Ruby 2.7.5, and RuboCop is clean after establishing repository-specific style overrides.
* RubyGems 3.1 does not reliably backtrack from dependencies that have raised their Ruby requirement. The gemspec therefore declares compatibility ceilings for the affected direct and transitive dependencies, and package smoke testing exercises a fresh consumer resolution.
* The development lockfile is retained for reproducibility. It does not constrain projects that consume the gem from Git.
* Version 0.8.4 is the first repository release from this fork. Its package installs and runs in an isolated Ruby 2.7.5 gem home, while the Rake release task explicitly refuses RubyGems publication.
* The Ruby 2.7-compatible dependency set is current within its declared constraints. Major upgrades remain for the Ruby 3.3 compatibility project.
* ActiveSupport's patched supported branches require newer Ruby. The client now loads only the Hash, Object and String extensions it uses, excluding the helpers affected by three low-severity advisories; the exact advisories are documented exceptions until the Ruby 3.3 upgrade.
* Both legacy hyperschema endpoints still respond, and the controlled live recorder completed four examples against DatoCMS with disposable-project teardown and cassette secret checks.
* The final offline suite passed 155 examples with 93.64% line coverage. Dependency audit, RuboCop, package build and isolated package smoke testing also passed.
* The first hosted CI run exposed a layout difference: Bundler cached dependencies under `vendor/bundle`, which RuboCop then scanned. The project configuration now excludes that dependency cache; a new hosted run is required to confirm the workflow end to end.
