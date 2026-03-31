Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  resource :session, only: %i[create destroy]
  resources :passwords, param: :token, only: %i[create update]

  get "up" => "rails/health#show", :as => :rails_health_check

  resources :manufacturers, only: %i[index show create update destroy]
  resources :machines, only: %i[index show create update destroy]
  resources :organizations, only: %i[index show create update destroy] do
    resources :organization_machines, only: %i[index show create update destroy] do
      resources :user_organization_machines, only: %i[index create destroy]
    end
  end
  resources :users, only: %i[index show create update destroy]
end
