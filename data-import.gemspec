# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "data-import/version"

Gem::Specification.new do |s|
  s.name        = "data-import"
  s.version     = DataImport::VERSION
  s.authors     = ['Michael Stämpfli', 'Yves Senn']
  s.email       = ['michael.staempfli@garaio.com', 'yves.senn@garaio.com']
  s.homepage    = ""
  s.summary     = %q{migrate your data to a better palce}
  s.description = %q{sequel based dsl to migrate data from a legacy database to a new home}

  s.rubyforge_project = "data-import"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "sqlite3"

  s.add_runtime_dependency "sequel"
  s.add_runtime_dependency "progressbar"
  s.add_runtime_dependency "activesupport"
  s.add_runtime_dependency "i18n"
end
