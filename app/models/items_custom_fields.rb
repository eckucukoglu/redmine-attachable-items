class ItemsCustomFields < ActiveRecord::Base
  unloadable

  self.table_name = 'items_custom_fields'

  has_many :items_custom_values

  validates :name, :field_format, :project_id, presence: true
end
