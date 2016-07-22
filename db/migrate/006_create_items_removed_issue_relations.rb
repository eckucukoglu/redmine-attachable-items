class CreateItemsRemovedIssueRelations < ActiveRecord::Migration
  def change
    create_table :items_removed_issue_relations do |t|
      t.references :issue, null: false
      t.string :item_unique_name, null: false
    end

    add_index :items_removed_issue_relations, :issue_id
  end
end
