require 'rspec/core/rake_task'

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
