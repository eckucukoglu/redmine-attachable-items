class CreateItemsCustomValues < ActiveRecord::Migration
  def change
    create_table :items_custom_values, :force => true do |t|
      t.references :items, index: true, foreign_key: true, null: false
      t.references :items_custom_fields, null: false
      t.column "value", :text
    end

    add_index :items_custom_values, :items_id
    # add_index :items_custom_values, :items_custom_fields_id
  end
end
