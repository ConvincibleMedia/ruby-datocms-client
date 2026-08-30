# Ruby Style Guide

* Use two spaces for logical indentation. Do not use tabs.
* Indent the body of every module and class by one logical level, including modules used only for namespacing.
* Do not add empty lines immediately inside module or class bodies.
* Use nested module and class declarations rather than compact namespace declarations such as `Dato::Local::Loader`.
* Use spaces for visual alignment.
* Use LF line endings for Ruby files.
* Prefer one top-level class or module per file. A formatter may colocate small core-class extensions that exist solely to support that formatter.
* Treat `.rubocop.yml` as the executable definition of Ruby formatting rules. Changes to formatting policy must update this guide and the RuboCop configuration together.
