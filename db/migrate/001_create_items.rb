class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :unique_name, null: false
      t.references :project, null: false
    end

    add_index :items, :unique_name
  end
end
