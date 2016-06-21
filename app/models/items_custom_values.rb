class ItemsCustomValues < ActiveRecord::Base
  unloadable

  self.table_name = 'items_custom_values'
  belongs_to :items
  belongs_to :items_custom_fields

  validates :items_id, :items_custom_fields_id, :value, presence: true
end
