# Todo


## Ruby compatibility

* Raise the gem's minimum supported Ruby version to 3.3.
  * Until then, retain Ruby 2.7.5 as the development baseline and keep the bundle, tests and other development tooling working on it.
  * Treat the eventual increase as a deliberate compatibility change for projects that remain pinned to Ruby 2.7.
  * Add Ruby 3.3 to continuous integration before changing the minimum, then remove the Ruby 2.7 job only with the compatibility change.


## Dependencies

* When the minimum reaches Ruby 3.3, upgrade ActiveSupport to a patched supported branch and remove the three documented Ruby 2.7 audit exceptions.
* Plan and test the Faraday 2 migration separately; it is a breaking dependency update rather than baseline maintenance.
* Revisit the remaining Ruby 2.7 compatibility ceilings after the minimum-version change.


## Distribution

* Continue distributing the fork by direct Git repository reference.
* If RubyGems publication becomes useful, choose a new package name such as `dato-legacy` and treat the rename and release process as a separate project.
