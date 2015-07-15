Rails.application.routes.draw do
  resources :accounts, :only => [:index]
  root :to => "accounts#index"
end
