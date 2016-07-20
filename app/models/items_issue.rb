class ItemsIssue < ActiveRecord::Base
  unloadable

  validates :item_id, :issue_id, presence: true
end
