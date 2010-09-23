require 'rubygems'
require 'test/unit'

gem 'activerecord', '~> 2.3'

require 'active_support'
require 'active_record'
require 'logger'

require 'attr_accessible_block'

ActiveRecord::Base.logger = Logger.new("test.log")
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

def setup_db
  ActiveRecord::Migration.verbose = false
  load "schema.rb"
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end
