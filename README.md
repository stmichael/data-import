# DataImport

[![Build Status](https://secure.travis-ci.org/garaio/data-import.png)](http://travis-ci.org/garaio/data-import)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/garaio/data-import)

data-import is a data-migration framework. The goal of the project is to provide a simple api to migrate data from a legacy schema into a new one. It's based on jeremyevans/sequel.

## Installation

```ruby
gem 'data-import'
```

you can put your migration configuration in any file you like. We suggest something like `mapping.rb`.
You can find the various ways to connect described in the [sequel docs](http://sequel.rubyforge.org/rdoc/files/doc/opening_databases_rdoc.html).

```ruby
source 'sqlite://legacy_blog.db'
target :adapter => :postgres, :host => 'localhost', :user => 'user', :password => 'password', :database => 'blog'

import 'Animals' do
  from 'tblAnimal', :primary_key => 'sAnimalID'
  to 'animals'

  mapping 'sAnimalID' => 'id'
  mapping 'strAnimalTitleText' => 'name'
  mapping 'sAnimalAge' => 'age'
  mapping 'convert threat to danger rating' do
    rating = ['none', 'medium', 'big'].index(arguments[:strThreat]) + 1
    {:danger_rating => rating}
  end
end
```

to run the import just execute:

```ruby
  mapping_path = Rails.root + 'mapping.rb'
  DataImport.run_config! mapping_path
```

if you execute the import frequently you can create a Rake-Task:

```ruby
desc "Imports the date from the source database"
task :import do
  mapping_path = Rails.root + 'mapping.rb'
  options = {}
  options[:only] = ENV['RUN_ONLY'].split(',') if ENV['RUN_ONLY'].present?

  DataImport.run_config! mapping_path, options
end
```

## Configuration

data-import provides a clean dsl to define your mappings from the legacy schema to the new one.

### Before Filter ###

data-import allows you to definie a global filter. This filter can be used to make global transformations like encoding fixes. You can define a filter, which downcases every string like so:

```ruby
before_filter do |row|
  row.each do |k, v|
    row[k] = v.downcase if v.respond_to?(:downcase)
  end
end
```

### Simple Mappings

You've already seen a very basic example of the dsl in the Installation-Section. This part shows off the features of the mapping-DSL.

#### Structure ####

every mapping starts with a call to `import` followed by the name of the mapping. You can name mappings however you like. The block passed to import contains the mapping itself. You can supply the source-table with `from` and the target-table with `to`. Make sure that you set the primary-key on the source-table otherwhise pagination is not working properly and the migration will fill up your RAM.

```ruby
import 'Users' do
  from 'tblUser', :primary_key => 'sUserID'
  to 'users'
```

#### Column-Mappings ####

You can create simple name-mappings with a call to `mapping`:

```ruby
mapping 'sUserID' => 'id'
mapping 'strEmail' => 'email'
mapping 'strUsername' => 'username'
```

If you need to process a column you can add a block. You have access to the entire record read from the source database. The return value of the block should be a hash or nil. Nil means no mapping at all and in case of a hash you have to use the column-names of the target-table as keys.

```ruby
mapping 'convert threat to danger rating' do
  rating = ['none', 'medium', 'big'].index(arguments[:strThreat]) + 1
  {:danger_rating => rating}
end
```

### Script mappings

If you have a more complex mapping than just reading from one source and writing each record to another, you can define script blocks. Inside a script block you can write ruby code that does your data conversion. You have access to the source and target database to read and write data.

```ruby
script 'my compex converion' do
  body do
    log_texts = source_database.db[:Logger].map {|record| record[:strText]}

    target_database.db[:log].insert(log_texts.join(','))
  end
end
```

`source_database.db` and `target_database.db` are sequel database objects. Look at the [sequel docs](https://github.com/jeremyevans/sequel) for more information.

### Dependencies

You can specify dependencies between definitions. Dependencies are always run before a given definition will be executed. Adding all necessary dependencies also allows you to run a set of definitions instead of everything.

```ruby
import 'Roles' do
  from 'tblRole', :primary_key => 'sRoleID'
  to 'roles'
end

import 'SubscriptionPlans' do
  from 'tblSubcriptionCat', :primary_key => 'sSubscriptionCatID'
  to 'subscription_plans'
end

import 'Users' do
  from 'tblUser', :primary_key => 'sUserID'
  to 'users'
  dependencies 'SubscriptionPlans'
end

import 'Permissions' do
  from 'tblUserRoles'
  to 'permissions'
  dependencies 'Users', 'Roles'
end
```

you can now run parts of your mappings using the :only option:

```ruby
DataImport.run_config! 'mappings.rb', :only => ['Users'] # => imports SubscriptionPlans then Users
DataImport.run_config! 'mappings.rb', :only => ['Roles'] # => imports Roles only
DataImport.run_config! 'mappings.rb', :only => ['Permissions'] # => imports Roles, SubscriptionPlans, Users and then Permissions
```

### Lookup-Tables

If you have tables referenced on other fields than their primary-key you need to perform lookups while migrating the data. data-import provides a feature called lookup-tables to basically create an index on any given field to the migrated primary-key.

The following example shows a table `People` which is linked to the table `Organizations`. Sadly the legacy-schema used the field :code from the `Organizations`-table as reference.

```ruby
import 'Organizations' do
  # define a lookup-table on the :sOrgId attribute named :sOrgId
  lookup_for :sOrgId

  # define a lookup-table on the :strCode attribute named :code
  lookup_for :code, :column => 'strCode'
end

import 'People' do
  dependencies 'Organizations'

  # you can then use the previously defined lookup-table on :code to get the primary-key
  reference 'Organizations', 'OrganizationCode' => :org_id, :lookup => :code
end
```

If you don't specify the option `:lookup` then data-import uses the lookup table called `:id`.

## Examples

you can learn a lot from the [integration specs](https://github.com/garaio/data-import/tree/master/spec/integration).

## Community

### Got a question?

Just send me a message and I'll try to get to you as soon as possible.

### Found a bug?

Please submit a new issue.

### Fixed something?

1. Fork data-import
2. Create a topic branch - `git checkout -b my_branch`
3. Make your changes and update the History.txt file
4. Push to your branch - `git push origin my_branch`
5. Send me a pull-request for your topic branch
6. That's it!
