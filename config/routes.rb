Rails.application.routes.draw do
  root 'products#index'
  resources :products, only: %i[index]

  resources :pagolatam, only: %i[] do
    collection do
      post :notify
    end
  end

  resources :orders, only: %i[index show] do
    collection do
      get :add_product
    end

    member do
      get :checkout
      post :purchase
      get :success
    end
  end
end
