require File.join(File.dirname(__FILE__),'lib/boot') unless defined?(ActiveRecord)
require 'test/unit'
require 'acts_as_versioned'

config = YAML::load(IO.read(File.dirname(__FILE__)+'/lib/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__)+'/debug.log')
ActiveRecord::Base.configurations = {'test' => config[ENV['DB'] || 'sqlite3']}
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])

class AAVTestCase < ActiveRecord::TestCase
  
  self.fixture_path               = File.dirname(__FILE__)+'/fixtures'
  self.use_instantiated_fixtures  = false
  self.use_transactional_fixtures = true
  
  setup :load_schema
  
  protected
  
  def load_schema
    load(File.dirname(__FILE__)+"lib/schema.rb")
    if ENV['DB'] == 'postgresql'
      ActiveRecord::Base.connection.execute "DROP SEQUENCE widgets_seq;" rescue nil
      ActiveRecord::Base.connection.remove_column :widget_versions, :id
      ActiveRecord::Base.connection.execute "CREATE SEQUENCE widgets_seq START 101;"
      ActiveRecord::Base.connection.execute "ALTER TABLE widget_versions ADD COLUMN id INTEGER PRIMARY KEY DEFAULT nextval('widgets_seq');"
    end
  end
  
end


class Landmark < ActiveRecord::Base
  acts_as_versioned :if_changed => [ :name, :longitude, :latitude ]
end

class Page < ActiveRecord::Base
  belongs_to :author
  has_many   :authors,  :through => :versions, :order => 'name'
  belongs_to :revisor,  :class_name => 'Author'
  has_many   :revisors, :class_name => 'Author', :through => :versions, :order => 'name'
  acts_as_versioned :if => :feeling_good? do
    def self.included(base)
      base.cattr_accessor :feeling_good
      base.feeling_good = true
      base.belongs_to :author
      base.belongs_to :revisor, :class_name => 'Author'
    end
    def feeling_good?
      @@feeling_good == true
    end
  end
end

module LockedPageExtension
  def hello_world
    'hello_world'
  end
end

class LockedPage < ActiveRecord::Base
  acts_as_versioned \
    :inheritance_column => :version_type, 
    :foreign_key        => :page_id, 
    :table_name         => :locked_pages_revisions, 
    :class_name         => 'LockedPageRevision',
    :version_column     => :lock_version,
    :limit              => 2,
    :if_changed         => :title,
    :extend             => LockedPageExtension
end

class SpecialLockedPage < LockedPage
end

class Author < ActiveRecord::Base
  has_many :pages
end

class Widget < ActiveRecord::Base
  acts_as_versioned :sequence_name => 'widgets_seq', :association_options => {
    :dependent => :nullify, :order => 'version desc'
  }
  non_versioned_columns << 'foo'
end

