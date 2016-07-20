class ItemsCustomValue < ActiveRecord::Base
  unloadable

  belongs_to :item
  belongs_to :items_custom_field

  validates :item_id, :items_custom_field_id, presence: true
end
