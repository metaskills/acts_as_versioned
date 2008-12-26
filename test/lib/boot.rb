
# Requiring ActiveRecord via RubyGems.

require 'rubygems'

project_root  = File.expand_path(File.join(File.dirname(__FILE__),'..','..'))
rails_version = ENV['RAILS_VERSION'] || '2.2.2'

['.','lib','test','test/models'].each do |test_lib|
  load_path = File.expand_path(File.join(project_root,test_lib))
  $LOAD_PATH.unshift(load_path) unless $LOAD_PATH.include?(load_path)
end

puts "Using ActiveRecord #{rails_version} from gems"
gem 'activerecord', rails_version
require 'active_record'


# Setting up ActiveRecord TestCase and fixtures. We make sure our setup runs before setup_fixtures.

FIXTURES_ROOT   = project_root + "/test/fixtures"
MIGRATIONS_ROOT = project_root + "/test/migrations"

require 'active_record/fixtures'
require 'active_record/test_case'


# Establishing the ActiveRecord connection.

arconfig = YAML::load(IO.read("#{project_root}/test/lib/database.yml"))
ActiveRecord::Base.logger = Logger.new("#{project_root}/test/debug.log")
ActiveRecord::Base.configurations = {'test' => arconfig[ENV['DB'] || 'sqlite3']}
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])


# Creating the DB schema.

load(File.dirname(__FILE__)+"/schema.rb")

if ENV['DB'] == 'postgresql'
  ActiveRecord::Base.connection.execute "DROP SEQUENCE widgets_seq;" rescue nil
  ActiveRecord::Base.connection.remove_column :widget_versions, :id
  ActiveRecord::Base.connection.execute "CREATE SEQUENCE widgets_seq START 101;"
  ActiveRecord::Base.connection.execute "ALTER TABLE widget_versions ADD COLUMN id INTEGER PRIMARY KEY DEFAULT nextval('widgets_seq');"
end

