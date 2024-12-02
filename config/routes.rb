Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  root "movies#index"

  resources :movies, only: %i[index] do
    get :recommendations, on: :collection
    get :user_rented_movies, on: :collection
    post :rent, on: :member
  end
end
