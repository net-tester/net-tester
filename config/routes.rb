Rails.application.routes.draw do
  resource :sites, :only => [:show, :destroy]
  get '*not_found' => 'application#routing_error'
  post '*not_found' => 'application#routing_error'
  put '*not_found' => 'application#routing_error'
  delete '*not_found' => 'application#routing_error'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
