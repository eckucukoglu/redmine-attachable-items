class ItemsIssues < ActiveRecord::Base
  unloadable

  validates :items_id, :issues_id, presence: true
end
