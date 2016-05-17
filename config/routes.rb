Rails.application.routes.draw do
  #resources :articles, only: [:index, :show]
  
  resources :articles, only: [:index, :show] do
    collection do
      post :import
      get :autocomplete # <= add this line
    end
  end
  root to: "articles#index"
  get 'articles/index'
  get 'articles/show'
end
