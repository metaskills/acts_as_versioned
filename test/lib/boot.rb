require 'rubygems'

project_root  = File.expand_path(File.join(File.dirname(__FILE__),'..','..'))
rails_version = ENV['RAILS_VERSION'] || '2.2.2'

['.','lib','test'].each do |test_lib|
  load_path = File.expand_path(File.join("#{project_root},#{test_lib}"))
  $LOAD_PATH.unshift(load_path) unless $LOAD_PATH.include?(load_path)
end

puts "Using ActiveRecord #{rails_version} from gems"
gem 'activerecord', rails_version

require 'active_record'
require 'active_record/fixtures'

FIXTURES_ROOT   = project_root + "/test/fixtures"
MIGRATIONS_ROOT = project_root + "/test/migrations"

require 'active_record/test_case'

