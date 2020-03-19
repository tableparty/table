Rails.application.routes.draw do
  resources :campaigns, only: %i[index new create show] do
    resources :maps, only: %i[new create], shallow: true
  end

  root controller: :campaigns, action: :index
end
