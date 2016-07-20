class CreateItemsIssues < ActiveRecord::Migration
  def change
    create_table :items_issues, :force => true do |t|
      t.references :item, null: false
      t.references :issue, null: false
    end

    add_index :items_issues, :issue_id
  end
end
