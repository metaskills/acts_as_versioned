require 'test/unit'
require File.join(File.dirname(__FILE__),'lib/boot') unless defined?(ActiveRecord)
require 'acts_as_versioned'

if ActiveRecord::VERSION::STRING >= '2.3.0'
  class ActiveSupport::TestCase
    include ActiveRecord::TestFixtures
    self.fixture_path = FIXTURES_ROOT
    self.use_instantiated_fixtures  = false
    self.use_transactional_fixtures = true
    def create_fixtures(*table_names, &block)
      Fixtures.create_fixtures(ActiveSupport::TestCase.fixture_path, table_names, {}, &block)
    end
  end
end

class AAVTestCase < ActiveRecord::TestCase
  
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures = false
  
  fixtures :all
  set_fixture_class :page_versions => Page::Version
  
  protected
  
  def assert_sql(*patterns_to_match)
    $queries_executed = []
    yield
  ensure
    failed_patterns = []
    patterns_to_match.each do |pattern|
      failed_patterns << pattern unless $queries_executed.any?{ |sql| pattern === sql }
    end
    assert failed_patterns.empty?, "Query pattern(s) #{failed_patterns.map(&:inspect).join(', ')} not found in:\n#{$queries_executed.inspect}"
  end
  
end

