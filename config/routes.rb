Rails.application.routes.draw do
  root 'products#index'
  resources :products, only: %i[index]

  resources :orders, only: %i[index show] do
    collection do
      get :add_product
    end

    member do
      get :purchase
    end
  end
end
