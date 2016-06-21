resources :project do
  resources :items do
    post 'custom_value', :to => 'items#add_custom_value', as: 'add_custom_value'
  end
  resources :items_custom_fields

end
