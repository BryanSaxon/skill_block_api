Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  resource :session, only: %i[create destroy]
  resources :passwords, param: :token, only: %i[create update]

  get "up" => "rails/health#show", :as => :rails_health_check

  resources :organizations, only: %i[index show create update destroy]
  resources :users, only: %i[index show create update destroy]
end
