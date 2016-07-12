class CreateItemsIssues < ActiveRecord::Migration
  def change
    create_table :items_issues, :force => true do |t|
      t.references :items, null: false
      t.references :issues, null: false
    end

    add_index :items_issues, :issues_id
  end
end
