Rails.application.routes.draw do
  resources :passwords, controller: "clearance/passwords", only: %i[create new]
  resource :session, only: [:create]

  resources :users, only: [:create] do
    resource :password,
             controller: "clearance/passwords",
             only: %i[create edit update]
  end

  get "/sign_in" => "sessions#new", as: "sign_in"
  delete "/sign_out" => "sessions#destroy", as: "sign_out"
  get "/sign_up" => "users#new", as: "sign_up"
  resources :campaigns, only: %i[index new create show] do
    resources :characters, only: %i[create edit update destroy]
    resources :creatures, only: %i[create edit update destroy]
    resources :maps, only: %i[new create edit update destroy] do
      resources :tokens, only: %i[new create edit update]
    end
  end

  resource :home, controller: :home, only: [:show]
  resource :demo, controller: :demo, only: [:show]

  root controller: :home, action: :show
end
