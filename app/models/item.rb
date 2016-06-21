class Item < ActiveRecord::Base
  unloadable
  validates :unique_name, :project_id, presence: true

  has_many :items_custom_values
end
