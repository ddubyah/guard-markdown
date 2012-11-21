require 'bundler/gem_tasks'

task :default => [:"specs:all"]

namespace :specs do
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new :all do |t|
    t.pattern = "spec/**/*_spec.rb"
    t.rspec_opts = ['--color', '--require spec_helper']
  end
end
