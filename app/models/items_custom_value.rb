class ItemsCustomValue < ActiveRecord::Base
  unloadable

  self.table_name = 'items_custom_values'
  belongs_to :item
  belongs_to :items_custom_field

  validates :item_id, :items_custom_field_id, presence: true
end
