
# Requiring ActiveRecord via RubyGems.

require 'rubygems'

PROJECT_ROOT  = File.expand_path(File.join(File.dirname(__FILE__),'..','..'))
AR_VERSION    = ENV['AR_VERSION'] || '2.2.2'

['.','lib','test','test/models'].each do |test_lib|
  load_path = File.expand_path(File.join(PROJECT_ROOT,test_lib))
  $LOAD_PATH.unshift(load_path) unless $LOAD_PATH.include?(load_path)
end

puts "Using ActiveRecord #{AR_VERSION} from gems"
gem 'activerecord', AR_VERSION
require 'active_record'


# Setting up ActiveRecord TestCase and fixtures. We make sure our setup runs before setup_fixtures.

FIXTURES_ROOT   = PROJECT_ROOT + "/test/fixtures"
MIGRATIONS_ROOT = PROJECT_ROOT + "/test/migrations"

require 'active_record/fixtures'
require 'active_record/test_case'


# Establishing the ActiveRecord connection.

arconfig = YAML::load(IO.read("#{PROJECT_ROOT}/test/lib/database.yml"))
ActiveRecord::Base.logger = Logger.new("#{PROJECT_ROOT}/test/debug.log")
ActiveRecord::Base.configurations = {'test' => arconfig[ENV['DB'] || 'sqlite3']}
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])


# Creating the DB schema.

ActiveRecord::Migration.verbose = false

load(File.dirname(__FILE__)+"/schema.rb")

if ENV['DB'] == 'postgresql'
  ActiveRecord::Base.connection.execute "DROP SEQUENCE widgets_seq;" rescue nil
  ActiveRecord::Base.connection.remove_column :widget_versions, :id
  ActiveRecord::Base.connection.execute "CREATE SEQUENCE widgets_seq START 101;"
  ActiveRecord::Base.connection.execute "ALTER TABLE widget_versions ADD COLUMN id INTEGER PRIMARY KEY DEFAULT nextval('widgets_seq');"
end

