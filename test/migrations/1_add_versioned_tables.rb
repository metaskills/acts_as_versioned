class AddVersionedTables < ActiveRecord::Migration
  
  def self.up
    drop_table :thing_versions rescue nil
    create_table :things, :force => true do |t|
      t.column :title, :text
      t.column :price, :decimal, :precision => 7, :scale => 2
      t.column :type, :string
    end
    Thing.create_versioned_table
  end
  
  def self.down
    Thing.drop_versioned_table
    drop_table :things rescue nil
  end
  
end
