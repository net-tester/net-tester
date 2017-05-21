Rails.application.routes.draw do
  resource :sites, :only => [:show, :destroy]
  resources :hosts, param: :name, :only => [:index, :show, :update, :destroy]
  get '*not_found' => 'application#routing_error'
  post '*not_found' => 'application#routing_error'
  put '*not_found' => 'application#routing_error'
  delete '*not_found' => 'application#routing_error'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
