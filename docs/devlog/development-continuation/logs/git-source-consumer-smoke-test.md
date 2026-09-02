# Git-source consumer smoke test


## Goals

* Exercise installation from the checked-out repository as a Git source at an explicit revision.
* Resolve dependencies into an isolated temporary consumer bundle.
* Verify library loading, version reporting and installed CLI help without replacing the built-package smoke test.
* Make dependency resolution, library loading and CLI failures readily distinguishable.


## Completion criteria

Complete locally and in hosted CI.

* The consumer lockfile records the repository and exact tested revision.
* The Git-sourced library and CLI pass under Ruby 2.7.5 and Ruby 3.3.
* Temporary consumer files and installed dependencies remain outside the repository and cannot affect packaging or RuboCop.


## Completed work

* Added `bin/smoke_git_source`, which resolves the checkout's exact `HEAD` revision through a local `file://` Git source.
* Isolated the temporary Gemfile, lockfile, Bundler configuration and installed dependencies beneath `/tmp` with cleanup on exit.
* Added explicit checks that the consumer lockfile records both the repository URI and exact revision.
* Added separately labelled dependency resolution, lock verification, library loading and CLI startup failures.
* Added the Git-source smoke test after the retained built-package smoke test in the shared CI matrix job.
* Corrected consumer activation by running Bundler from the temporary consumer directory and requiring `dato` after Bundler setup rather than through Ruby's command-line `-r` processing.


## Local evidence

* Bash syntax validation passed.
* Ruby 2.7.5 and Ruby 3.3.6 each resolved 47 gems into a fresh `/tmp/dato-git-smoke.*` bundle.
* Both consumer lockfiles recorded the `file://` repository source and exact tested revision.
* Both runtimes loaded the Git-sourced library and reported Dato version 0.8.4.
* Installed CLI help passed on both runtimes.


## Hosted evidence

Both Ruby matrix jobs passed the Git-source consumer check in GitHub Actions while retaining the separate built-package smoke test.


## Status

Complete.
