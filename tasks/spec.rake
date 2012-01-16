require 'rspec/core/rake_task'

namespace :spec do
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern    = "spec/unit/**/*_spec.rb"
  end

  RSpec::Core::RakeTask.new(:integration) do |t|
    t.pattern    = "spec/integration/**/*_spec.rb"
  end

  RSpec::Core::RakeTask.new(:acceptance) do |t|
    t.pattern    = "spec/acceptance/**/*_spec.rb"
  end

end

task :spec => ['spec:unit', 'spec:integration', 'spec:acceptance']
