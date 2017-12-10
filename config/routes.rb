Rails.application.routes.draw do
  root 'logins#new'
  resources :users
  resources :albums do
    member do
      get 'upload'
    end
    resources :payments, only: [:new, :create]
  end
  resources :photos, only: [:postback, :show, :destroy] do
    post 'postback', on: :member
  end
  resources :logins, only: [:new, :create, :destroy]
  get '/auth', to: 'logins#auth'
  get '/sent', to: 'logins#sent'
end
