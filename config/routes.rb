Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: :rails_admin
  devise_for :admins
  devise_for :users,controllers: {registrations: "users/registrations", sessions: "users/sessions"}
  root "bus#index"
  get "bus/search", to:"bus#search", as: :search_bus
  get "bus/book/id", to:"bus#book", as: :book
  get "wallet/index", to:"wallet#index", as: :wallets
  get "bus/seats", to:"bus#seats", as: :seats
  get "bus/buses", to:"bus#buses", as: :buses
  get "bus/statement/:id", to:"bus#statement", as: :statement
  get "bus/statements", to:"bus#statements", as: :my_statements
  get "wallet/:id", to:"wallet#new", as: :new_wallet
  post 'wallet/:id', to: 'wallet#create'
  get 'reservation/index', to:'reservation#index', as: :reservation
  get 'reservation/show', to:'reservation#show', as: :my_reservations
  get 'reservation/cancel', to:'reservation#cancel', as: :cancel
  get 'reservation/cancelled', to:'reservation#cancelled', as: :cancel_ticket

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
