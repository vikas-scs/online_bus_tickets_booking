Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: :rails_admin
  devise_for :admins
  devise_for :users,controllers: {registrations: "users/registrations", sessions: "users/sessions"}
  root "bus#index"
  get "bus/search", to:"bus#search", as: :search_bus
  get "bus/book/id", to:"bus#book", as: :book
  get "wallet/index", to:"wallet#index", as: :wallets
  # get "bus/seats/id", to:"bus#seats", as: :seats
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
