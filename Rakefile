# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

# Keep build and install tasks while preventing publication under the upstream name.
Rake::Task["release"].clear
desc "Refuse publication of the repository-only fork"
task :release do
  abort "This fork is repository-only and cannot publish the existing dato gem"
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "-b"
end

task default: :spec
