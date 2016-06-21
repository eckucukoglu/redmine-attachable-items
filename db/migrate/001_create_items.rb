class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :unique_name, null: false
      t.references :project, index: true, foreign_key: true, null: false
    end

    add_index :items, :unique_name
    add_index :items, :project_id
  end
end
