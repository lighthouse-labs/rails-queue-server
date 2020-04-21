LaserShark::Application.routes.draw do

  resources :projects, only: [:index, :show] do
    resources :activities, only: [:index, :show, :edit]
    resources :evaluations, only: [:index, :show, :new, :create, :edit, :update] do
      member do
        put :start_marking
        put :cancel_marking
        delete :cancel
      end
    end
  end

  resources :tech_interview_templates, only: [:index, :show] do
    resources :interviews, controller: 'tech_interviews', only: [:new, :create]
  end
  resources :tech_interviews, only: [:show, :edit, :update] do
    member do
      get :confirm
      patch :complete
      patch :start
      patch :stop
    end
  end

  resources :questions
  resource :queue, only: [:show], controller: 'queue' do
    post 'provided_assistance'
    post 'end_assistance'
  end

  resource :queue_tasks, only: [:show], controller: 'queue_tasks' do
    post 'provided_assistance'
    post 'end_assistance'
    get 'students'
    get 'cohorts'
    get 'evaluations'
    get 'tech_interviews'
    get 'day_activities'
  end

  resources :quiz_submissions, only: [:show]

  resources :quizzes, only: [:index, :show, :new, :create, :destroy] do
    resources :quiz_submissions, only: [:new, :create]
    get 'add_question', to: 'quizzes#add_question', as: 'add_question'
    get 'link_question', to: 'quizzes#link_question', as: 'link_question'
    delete 'remove_question/:question_id', to: 'quizzes#remove_question', as: 'remove_question'
  end

  get '/i/:code', to: 'invitations#show', as: 'invitation' # student/teacher invitation handler
  # get 'prep'  => 'setup#show' # temporary
  resources :prep, controller: 'preps', only: [:index, :show] do
    resources :activities, only: [:index, :show, :edit]
  end

  resources :workbooks, only: [:index, :show] do
    resources :activities, only: [:show]
  end

  resources :teacher_resources, only: [:index, :show] do
    resources :activities, only: [:show]
  end

  # get 'setup' => 'setup#show' # temporary

  post 'github-hook' => 'github_webhook_events#create'

  post 'zoom-hook' => 'zoom_webhook_events#create'

  root to: 'home#show'
  get '/welcome', to: 'welcome#show'

  # STUDENT / TEACHER AUTH
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/github', as: 'github_session'
  resource :session, only: [:new, :destroy] do
    put :revert_admin
    put :impersonate, on: :member
  end
  # resource :registration, only: [:new, :create]

  resource :profile, only: [:edit, :update]
  resources :feedbacks, only: [:index, :update] do
    member do
      get :modal_content
    end
  end

  get 'assistance_requests', to: redirect('/queue')

  resources :prep_assistance_requests, only: [:create]

  resources :students, only: [:index, :show] do
    resources :code_reviews, only: [:create]
    member do
      get :new_code_review_modal
    end
  end

  resources :incomplete_activities, only: [:index]

  # resources :code_reviews, only: [:destroy] do
  #   member do
  #     post :end
  #     get :view_code_review_modal
  #   end
  # end

  # CONTENT BROWSING
  resources :days, param: :number, only: [:show] do
    resources :activities, only: [:show, :edit]
    resources :feedbacks, only: [:create, :new], controller: :day_feedbacks

    resource :info, only: [:edit, :update], controller: 'day_infos'
  end

  resources :activities, only: [:index, :show] do
    resource :activity_submission, only: [:create, :destroy]
    resource :submission_with_feedback, only: [:create], controller: 'activity_submission_with_feedback'
    resources :answers, only: [:update, :index], controller: 'activity_answers'
    resources :activity_feedbacks, only: [:index] do
      collection do
        get :rating_stats
        get :ratings_by_month
      end
    end
    resource :my_feedback, only: [:update], controller: 'my_activity_feedback'
    resources :lectures, except: [:index]
  end

  resources :cohorts, only: [] do
    resources :students, only: [:index] # cohort_students_path(@cohort)
    put :switch_to, on: :member
  end

  resources :code_reviews, only: [:index, :show, :new, :create]

  resources :streams, only: [:index, :show]

  resources :teachers, only: [:index, :show] do
    member do
      get :feedback
      post :remove_mentorship
      post :add_mentorship
    end
  end

  get '/assessment_tests', to: redirect('/admin/programming_tests')

  resources :lectures, only: [:index]

  resource :github_education, controller: 'github_education', only: [:show] do
    put :claim
    put :skip
  end

  resources :programming_tests, only: [] do
    resource :attempt, controller: :programming_test_attempts, only: [:show, :create]
  end

  # Wallboard
  namespace :wallboard do
    resources :assistances, only: [:index]
    resources :teachers, only: [:index]
    resources :calendars, only: [:index]
  end

  # CSV Endpoint
  namespace :csv_endpoint do
    resources :assistances, only: [:index]
    resources :feedbacks, only: [:index]
    resources :tech_interviews, only: [:index]
    resources :evaluations, only: [:index]
  end

  # TEACHER
  namespace :teacher do
    resources :students, only: [:show, :index]
    resources :evaluations, only: [:index]
    resources :assistances, only: [:index]
    resources :tech_interviews, only: [:index]
    resources :cohort_switcher, only: [:index]
    resources :video_conferences, only: [:show, :update, :create]

    resources :cohorts, only: [] do
      resources :programming_tests, only: [:show] do
        resources :student_submissions, only: [:show]
      end
    end
  end

  # ADMIN
  namespace :admin do
    root to: 'dashboard#show'
    resources :students, only: [:index, :update, :edit, :destroy] do
      member do
        get :modal_content
        put :toggle_tech_interviews
      end
      resource :rollover, only: [:new, :create]
    end
    resources :teacher_stats, only: [:index, :show] do
      member do
        get :assistance
        get :feedback
      end
    end
    resources :users, only: [:index] do
      member do
        post :reactivate
        post :deactivate
        post :enrol_in_cohort
      end
      # admins can make other users admins / non-admins
      resource :adminification, only: [:create, :destroy]
      resource :proctor_visibility, only: [:create, :destroy]
    end
    resources :cohorts do
      resources :curriculum_breaks, only: [:new, :create, :edit, :update, :destroy]
    end
    resources :feedbacks, except: [:edit, :update, :destroy]
    resources :teacher_feedbacks, only: [:index]
    resources :curriculum_feedbacks, only: [:index]
    resources :queue_stats, only: [:index]
    resources :day_feedbacks, except: [:destroy] do
      member do
        post :archive
        delete :archive, action: :unarchive
      end
    end

    resources :prep_stats, only: [:index]

    # Outcomes CRUD
    resources :outcomes
    resources :item_outcomes, only: [:create, :destroy]
    resources :categories do
      resources :skills do
        member do
          get :autocomplete
        end
      end
    end

    resources :activities, only: [:index]
    resources :evaluations, only: [:index]
    resources :assistances, only: [:index]
    # Projects CRUD
    resources :projects, only: [:new, :create, :edit, :update, :destroy]

    resources :deployments
  end

  # To test 500 error notifications on production
  get 'error-test' => 'test_errors#create'

  get '/:uuid', to: 'activities#show', constraints: { uuid: /[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/i }, as: :activity_by_uuid

end
