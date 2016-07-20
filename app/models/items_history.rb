class ItemsHistory < ActiveRecord::Base
  unloadable
  validates :project_id, :user_id, :action_time, :action_type, :object_type, :object_id, presence: true
end
