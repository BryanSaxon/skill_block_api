Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  resource :session, only: %i[create destroy]
  resources :passwords, param: :token, only: %i[create update]
  get "registrations/:token", to: "registrations#show", as: :registration
  post "registrations/:token", to: "registrations#create"

  get "up" => "rails/health#show", :as => :rails_health_check

  resources :manufacturers, only: %i[index show create update destroy]
  resources :machines, only: %i[index show create update destroy]
  resources :organizations, only: %i[index show create update destroy] do
    resources :invitations, only: %i[index create destroy]
    resources :documents, only: %i[index show create destroy]
    resources :users, only: %i[index show update destroy]
    resources :curricula, only: %i[index show update] do
      member { post :publish }
      resources :curriculum_modules, only: [], path: "modules" do
        member { patch :update, to: "curriculum_module_edits#update" }
      end
      collection { post :generate }
    end
    resources :organization_machines, only: %i[index show create update destroy] do
      resources :user_organization_machines, only: %i[index create destroy]
      resources :telemetry_readings, only: %i[index], path: "telemetry"
      resources :alerts, only: %i[index show] do
        member { post :acknowledge }
      end
      member { post :transition }
    end
  end

  resources :notifications, only: %i[index] do
    member { patch :mark_read }
    collection { post :mark_all_read }
  end

  resources :training_assignments, only: %i[index show create update destroy] do
    collection { post :bulk }
    resources :curriculum_modules, only: [], path: "modules" do
      member do
        post :start
        post :submit_answer
        post :complete
      end
    end
  end

  get "manager/dashboard", to: "manager_dashboard#show"
  get "manager/compliance_report", to: "curricula#compliance_report"

  # ── Simulator ingest (X-Simulator-Key auth) ───────────────────────────────
  namespace :simulator do
    post :telemetry, to: "/simulator_ingest#telemetry"
    post :fault, to: "/simulator_ingest#fault"
    post :resolve_alerts, to: "/simulator_ingest#resolve_alerts"
    post :reset, to: "/simulator_ingest#reset"
  end
end
