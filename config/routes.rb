Rails.application.routes.draw do
  get 'tickets/new'
  get 'tickets/create'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :tickets, only: [:new, :create]
  root "tickets#new"
end
