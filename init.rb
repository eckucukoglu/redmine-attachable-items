require_dependency 'attitems'
require_dependency 'items_hook_listener'

Redmine::Plugin.register :attitems do
  name 'Attachable Items'
  url 'https://github.com/eckucukoglu/redmine-attachable-items'
  description 'Attach customizable items to issues. Items can have custom fields.'
  author 'Emre Can Kucukoglu'
  author_url 'http://eckucukoglu.com'
  version '0.0.2'
  requires_redmine version_or_higher: '2.5.2'

  settings({
     :partial => 'settings/attitems',
     :default => {
       'issue_label' => 'Attach Item:'
      }
  })

  menu :project_menu, :items, { :controller => 'items', :action => 'index' }, :caption => 'Items', :after => :files, :param => :project_id

  project_module :items do
    permission :view_items, :items => :index, :require => :member
    permission :create_items, :items => [:new, :create, :edit, :add_custom_value, :update, :destroy]
    permission :create_custom_fields, :items_custom_fields => [:new, :create, :edit, :update, :destroy]
  end
end
