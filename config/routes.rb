Rails.application.routes.draw do
  resources :articles, only: [:index, :show]
  root to: "articles#index"
  get 'articles/index'
  get 'articles/show'
end
