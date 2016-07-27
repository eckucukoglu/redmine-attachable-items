class CreateItemsHistories < ActiveRecord::Migration
  def change
    create_table :items_histories do |t|
      t.references :project, null: false
      t.references :user, null: false
      t.datetime :action_time, null: false
      t.string :action_type, null: false
      t.string :object_type, null: false
      t.integer :object_id, null: false
      t.string :field_name
      t.string :old_value
      t.string :value
    end

  end
end
