require 'test/unit'
require File.join(File.dirname(__FILE__),'lib/boot') unless defined?(ActiveRecord)
require 'acts_as_versioned'

class AAVTestCase < ActiveRecord::TestCase
  
  fixtures :all
  set_fixture_class :page_versions => Page::Version
  
  
  
end

