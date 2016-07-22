class ItemsRemovedIssueRelations < ActiveRecord::Base
  unloadable

  validates :issue_id, :item_unique_name, presence: true
end
