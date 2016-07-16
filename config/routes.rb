Rails.application.routes.draw do
  get 'users/new'

  get 'static_pages/about'

  #resources :articles, only: [:index, :show]

  resources :articles, only: [:index, :show] do
    collection do
      post :import
      get :autocomplete
    end
  end
  root to: "articles#index"
  get 'articles/index'
  get 'articles/show'
  get '/about', to: 'static_pages#about', as: 'about_page'
  get '/websites', to: 'static_pages#websites', as: 'website_page'
  get '/projects', to: 'static_pages#projects', as: 'project_page'
  get ':title' => 'articles#show', :as => :article_details 
end
