namespace :postgres do
  desc 'Creates a database for the tests of this gem'
  task :setup do
    `createdb data_import_test`
  end
end
