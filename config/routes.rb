Rails.application.routes.draw do
  resources :campaigns, only: %i[index new create show]

  root controller: :campaigns, action: :index
end
