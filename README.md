# DataImport

[![Build Status](https://secure.travis-ci.org/stmichael/data-import.png)](http://travis-ci.org/stmichael/data-import)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/stmichael/data-import)

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
    rating = ['none', 'medium', 'big'].index(row[:strThreat]) + 1
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

### Providing options ###

You may want to make your mappings configurable. Any options you pass into DataImport.run_config! will be passed through to the evaluation context of the provided mappings.

```ruby
import 'Things' do
  if options[:validate_rows]
    validate do ... end
  end

  seeds options[:seeds]
end

DataImport.run_config! 'path/to/mapping.rb', { :validate_rows => true, :seeds => { :key => value } }
```


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

#### Data source

In simple cases you would read from one table and write to another.

```ruby
import 'Items' do
  from 'tblItem'
  to 'items'
end
```

This is not always sufficient. This gem allows you to specify a custom
data source using the
[sequel syntax](https://github.com/jeremyevans/sequel) or plain SQL.

```ruby
import 'Items' do
  from 'items' do |sequel|
    sequel[:tblItems].join(:tblOrderItems, :sItemID => :sID)
  end
  to 'items'
end
```

or

```ruby
import 'Items' do
  from 'items' do |sequel|
    sequel[<<-SQL
SELECT *
FROM tblItems
INNER JOIN tblOrderItems ON tblOrderItems.sItemID = tblItems.sID
SQL
          ]
    sequel[:tblItems].join(:tblOrderItems, :sItemID => :sID)
  end
  to 'items'
end
```

#### Data output

By default a new record will be inserted for record read from the
source. This behaviour can be changed. For example you may want to
update existing records.

```ruby
import 'Article Authors' do
  from 'tblArticleAbout', :primary_key => 'sID'
  to 'articles', :mode => :update

  mapping 'lArticleId' => 'id'
  mapping 'strWho' => 'author'
end
```

With `:mode => :update` you tell data-import to update a record
instead of inserting a new one. You have to specify a mapping for the
primary key of the target table. If there is no value for the primary
key then nothing will be updated.

There is also a unique writer to filter double records.

```ruby
import 'Cities' do
  from 'tblCities', :primary_key => 'sID'
  to 'cities', :mode => [:unique, :columns => [:name, :zip]]

  mapping 'strName' => 'name'
  mapping 'sZip' => 'zip'
  mapping 'strShort' => 'short_name'
end
```

Passing the option `:mode => [:unique, :columns => [:name, :zip]]`
makes data-import use a unique writer. `:columns` must be an array of
column which will be used to identify a double record. Before a new
record will be inserted, data-import makes a select on the target
table with the defined columns. So depending on the size of your
table, you may consider adding an (unique) index on those columns to
speed up the import.

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
  rating = ['none', 'medium', 'big'].index(row[:strThreat]) + 1
  {:danger_rating => rating}
end
```

#### Seed data

If you have static data that needs to be inserted you can used to
following feature:

```ruby
import 'managers' do
  from 'tblManagers'
  to 'managers'

  seed :earns_much_money => true, :has_emplyees => true
end
```

#### After row blocks

Use after row blocks to specify some logic that will be executed after
a row has been inserted.

```ruby
import 'Sales Leads' do
  from 'SL_NewLeads', :primary_key => 'slNewLeadsID'
  to 'sales_leads'

  mapping 'slNewLeadsID' => :id

  after_row do
    target_database[:contacts].insert(:firstname => row[:slName1],
                                      :lastname => row[:slName2])
  end
end
```

#### Row validation

Rows can be validated before insertion.

```ruby
import 'People' do
  from 'Person'
  to 'females'

  mapping 'Name' => :name
  mapping 'Gender' => :gender

  validate_row do
    if mapped_row[:gender] == 'f'
      true
    else
      logger.info "Row #{row} skipped since the gender is male"
      false
    end
  end
end
```

Inside the validation block you have access to the row read from the
data source (`row`) and to the row with all mappings applied
(`mapped_row`). If the result of the validation block is evaluated to
true, then the row will be inserted into the target table. If the
result is false, insertion will be skipped.

### Script mappings

If you have a more complex mapping than just reading from one source
and writing each record to another, you can define script
blocks. Inside a script block you can write ruby code that does
your data conversion. The whole block runs in a transaction to ensure
consistency.

```ruby
script 'my compex converion' do
  body do
    log_texts = source_database.db[:Logger].map {|record| record[:strText]}

    target_database.db[:log].insert(log_texts.join(','))
  end
end
```

`source_database.db` and `target_database.db` are sequel database objects. Look at the
[sequel docs](https://github.com/jeremyevans/sequel) for more information.

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

  # or you can do the same thing manually (this also works in script blocks)
  mapping 'organization code' do
    {:org_id => definition('Organizations').identify_by(:code, row['strCode'])}
  end
end
```

If you don't specify the option `:lookup` then data-import uses the
lookup table called `:id`.

### Logger

In every block, be this mapping, after_row, script body, validation, etc.,
you have access to a logger, which can be accessed as follows:

```ruby
import 'Animals' do
  # source and target config

  # mapping config

  validate_row do
    logger.info "animal name has been mapped from #{row[:strName]} to #{mapped_row[:name]}"
  end
end
```

The logger supports the standard log levels debug, info, warn, error
and fatal.

This gem supports two different kinds of logging. The full logger
prints every bit information. By default this will be printed to a
file called import.log in the project root. The important logger only
prints messages of levels warn, error or fatal, which will be
displayed on STDOUT be default. The file import.log will therefore
hold every message you log in the data migration process. On STDOUT
will only see severe messages beside the progress bar. The reason for
this distinction is that you don't want STDOUT to be flooded by debug
messages.

Full and important logger can be configured as follows:

```ruby
DataImport.full_logger = Logger.new(STDOUT)
DataImport.important_logger = Logger.new(STDERR)
```

You can apply any object that provides the methods `debug`, `info`,
`warn`, `error` and `fatal`.

## Examples

you can learn a lot from the [acceptance specs](https://github.com/stmichael/data-import/tree/master/spec/acceptance).

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
