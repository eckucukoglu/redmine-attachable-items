require_dependency 'attitems'

Redmine::Plugin.register :attitems do
  name 'Attachable Items plugin'
  url 'https://github.com/eckucukoglu/attitems'
  description 'This is a plugin for Redmine'
  author 'Emre Can Kucukoglu'
  author_url 'http://eckucukoglu.com/'
  version '0.0.1'
  requires_redmine version_or_higher: '2.5.2'

  settings partial: 'settings/attitems', default: {}

  menu :project_menu, :items, { :controller => 'items', :action => 'index' }, :caption => 'Items', :after => :files, :param => :project_id

  project_module :items do
    # permission :add_custom_fields_to_items, :items_custom_fields => [:new]

    permission :view_items, :items => :index, :require => :member
    permission :create_items, :items => [:new, :create, :edit, :add_custom_value, :update, :destroy]

    permission :create_custom_fields, :items_custom_fields => [:new, :create, :edit, :update, :destroy]

    # permission :view_items, :items => :index, :require => :member
    # permission :create_items, :items => [:new, :create, :edit], :require => :member
    # permission :update_items, :items => :delete, :require => :member
  end
end

Rails.configuration.to_prepare do
  AttachableItems.setup
end
