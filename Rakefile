require "bundler/gem_tasks"
require 'rspec/core/rake_task'

desc "Run the tests"
RSpec::Core::RakeTask.new(:test) do |t|
  t.rspec_opts = ['--color', '-f d']
  t.pattern = 'spec/*/*_spec.rb'
end


task :default => [:spec_prep, :test, :spec_clean]