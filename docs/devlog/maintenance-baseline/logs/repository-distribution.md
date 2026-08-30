# Repository distribution


## Outcome

The maintained fork is now documented and configured for direct Git repository consumption. Version 0.8.4 identifies the fork in its metadata, retains upstream authorship, and makes no claim that this repository can publish the existing `dato` gem.


## Changes

* Replaced RubyGems installation and release instructions with a Bundler Git source and repository maintenance commands.
* Added source and changelog metadata for the maintained repository.
* Added an explicit refusal to the inherited `rake release` task.
* Recorded that a future RubyGems package may use another name, such as `dato-legacy`, but did not select or configure one.
* Added continuous integration for linting, specs, package construction, and isolated package smoke testing, with no publication step or credentials.


## Evidence

* `rake build` produced `pkg/dato-0.8.4.gem` on Ruby 2.7.5.
* The package metadata reports version 0.8.4, Ruby `>= 2.7.5`, and the maintained repository URLs.
* A fresh package installation resolved and installed 47 gems, loaded `dato`, and ran the installed CLI help command successfully.
* `rake release` exited unsuccessfully with the repository-only publication message before any release work.


## Status

Complete.
