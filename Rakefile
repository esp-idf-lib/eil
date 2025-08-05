# frozen_string_literal: true

require "shellwords"

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: [:spec, :rubocop]

desc "Build documentation"
task :doc do
  extra_files = %w[
    LICENSE.txt
  ]
  sh "yard doc - #{extra_files.map(&:shellescape).join}"
end
