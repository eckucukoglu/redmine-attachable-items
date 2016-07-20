class CreateItemsCustomValues < ActiveRecord::Migration
  def change
    create_table :items_custom_values, :force => true do |t|
      t.references :item, null: false
      t.references :items_custom_field, null: false
      t.column "value", :text
    end

    add_index :items_custom_values, :item_id
  end
end
