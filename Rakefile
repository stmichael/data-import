require "bundler/gem_tasks"

require 'rspec/core/rake_task'

namespace :spec do
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern    = "spec/unit/**/*_spec.rb"
  end

  RSpec::Core::RakeTask.new(:integration) do |t|
    t.pattern    = "spec/integration/**/*_spec.rb"
  end
end

task :spec => ['spec:unit', 'spec:integration']
task :default => :spec

namespace :ci do
  task :setup do
    include FileUtils

    rm_rf 'reports'
    mkdir_p 'reports/rspec'
  end

  RSpec::Core::RakeTask.new(:rspec => :setup) do |t|
    t.rspec_opts = ['--no-color',
                    '-r ./spec/junit_formatter.rb',
                    '-f "JUnitFormatter"',
                    '-o reports/rspec/junit.xml']
    t.pattern    = "spec/**/*_spec.rb"
  end
end
