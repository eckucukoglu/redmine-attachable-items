class ItemsCustomField < ActiveRecord::Base
  unloadable

  has_many :items_custom_value

  validates :name, :field_format, :project_id, presence: true
end
