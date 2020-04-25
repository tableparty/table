Rails.application.routes.draw do
  resources :passwords, controller: "clearance/passwords", only: %i[create new]
  resource :session, controller: "clearance/sessions", only: [:create]

  resources :users, only: [:create] do
    resource :password,
             controller: "clearance/passwords",
             only: %i[create edit update]
  end

  get "/sign_in" => "clearance/sessions#new", as: "sign_in"
  delete "/sign_out" => "clearance/sessions#destroy", as: "sign_out"
  get "/sign_up" => "clearance/users#new", as: "sign_up"
  resources :campaigns, only: %i[index new create show] do
    resources :characters, only: %i[create edit update destroy]
    resources :creatures, only: %i[create edit update destroy]
    resources :maps, only: %i[new create], shallow: true do
      resources :tokens, only: %i[new create]
    end
  end

  root controller: :campaigns, action: :index
end
