class CreateItemsCustomFields < ActiveRecord::Migration
  def change
    create_table :items_custom_fields, :force => true do |t|
      t.column "name", :string, :limit => 30, :default => "", :null => false
      t.column "field_format", :string, :limit => 30, :default => "", :null => false
      t.column "default_value", :text
      t.references :project, index: true, foreign_key: true
    end

  end
end
