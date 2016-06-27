LaserShark::Application.routes.draw do

  resources :projects, only: [:index, :show] do
    resources :activities
    resources :evaluations, only: [:index, :show, :new, :create, :edit, :update] do
      get 'start_marking', to: 'evaluations#start_marking'
      get 'cancel_evaluation', to: 'evaluations#cancel_evaluation'
    end
  end

  resources :questions

  resources :quiz_submissions, only: [:show]

  resources :quizzes, only: [:index, :show, :new, :create, :destroy] do
    resources :quiz_submissions, only: [:new, :create]
    get 'add_question', to: 'quizzes#add_question', as: 'add_question'
    get 'link_question', to: 'quizzes#link_question', as: 'link_question'
    delete 'remove_question/:question_id', to: 'quizzes#remove_question', as: 'remove_question'
  end

  match "/websocket", :to => ActionCable.server, via: [:get, :post]

  get '/i/:code', to: 'invitations#show' # student/teacher invitation handler
  # get 'prep'  => 'setup#show' # temporary
  resources :prep, controller: 'preps', :only => [:index, :show] do
    resources :activities
  end

  # get 'setup' => 'setup#show' # temporary

  post 'github-hook' => 'github_webhook_events#create'

  root to: 'home#show'
  get '/welcome', to: 'welcome#show'

  # STUDENT / TEACHER AUTH
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/github', as: 'github_session'
  resource :session, :only => [:new, :destroy]
  # resource :registration, only: [:new, :create]

  resource :profile, only: [:edit, :update]
  resources :feedbacks, only: [:index, :update] do
    member do
      get :modal_content
    end
  end

  resources :assistance_requests, only: [:index, :create, :destroy] do
    collection do
      delete :cancel
      get :status
      get :queue
    end
    member do
      post :start_assistance
    end
  end

  resources :students, only: [:index, :show] do
    resources :code_reviews, only: [:create]
    member do
      get :new_code_review_modal
    end
  end

  resources :incomplete_activities, only: [:index]
  resources :search_activities, only: [:index]

  # resources :code_reviews, only: [:destroy] do
  #   member do
  #     post :end
  #     get :view_code_review_modal
  #   end
  # end

  # CONTENT BROWSING
  resources :days, param: :number, only: [:show] do
    resources :activities, only: [:new, :create, :show, :edit, :update]
    resources :feedbacks, only: [:create, :new], controller: :day_feedbacks

    resource :info, only: [:edit, :update], controller: 'day_infos'
  end

  resources :activities, only: [:index] do
    resource :activity_submission, only: [:create, :destroy]
    resource :submission_with_feedback, only: [:create], controller: 'activity_submission_with_feedback'
    resources :messages, controller: 'activity_messages'
    resources :recordings, only: [:new, :create]
    resources :activity_feedbacks, only: [:create]
  end

  resources :cohorts, only: [] do
    resources :students, only: [:index]    # cohort_students_path(@cohort)
    resources :code_reviews

    put :switch_to, on: :member
  end

  resources :recordings

  resources :streams, only: [:index, :show]

  resources :teachers, only: [:index, :show] do
    member do
      get :feedback
      post :remove_mentorship
      post :add_mentorship
    end
  end

  # TEACHER
  namespace :teacher do
    resources :students, only: [:show]
  end

  # ADMIN
  namespace :admin do
    root to: 'dashboard#show'
    resources :students, only: [:index, :update, :edit] do
      member do
        post :reactivate
        post :deactivate
        get :modal_content
      end
    end
    resources :teacher_stats, only: [:index, :show] do
      member do
        get :assistance
        get :feedback
      end
    end

    resources :cohorts, except: [:destroy]
    resources :feedbacks, except: [:edit, :update, :destroy]
    resources :teacher_feedbacks, only: [:index]
    resources :curriculum_feedbacks, only: [:index]
    resources :day_feedbacks, except: [:destroy] do
      member do
        post :archive
        delete :archive, action: :unarchive
      end
    end

    #Outcomes CRUD
    resources :outcomes
    resources :item_outcomes, only: [:create, :destroy]
    resources :categories do
      resources :skills do
        member do
          get :autocomplete
        end
      end
    end

    #Projects CRUD
    resources :projects, only: [:new, :create, :edit, :update, :destroy]
  end

  # To test 500 error notifications on production
  get 'error-test' => 'test_errors#create'

  get '/:uuid', to: 'activities#show', constraints: { uuid: /[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}/i }

end
