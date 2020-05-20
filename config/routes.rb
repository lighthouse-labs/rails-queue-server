LaserShark::Application.routes.draw do

  resources :queue, only: [:index, :show], controller: 'queue' do
    post 'provided_assistance'
    get 'students', on: :collection
    get 'cohorts', on: :collection
    get 'teachers', on: :collection
    get 'day_activities', on: :collection
    get 'settings', on: :collection
    put 'settings' => 'queue_tasks#update_settings', on: :collection
  end

  resource :assistance_requests, only: [:create, :update]

  resource :token, only: [:create]

  resources :compass_instances, only: [:create]

  # ADMIN
  namespace :admin do
    resources :queue_tasks
  
    resources :feedbacks
  
    resources :assistance_requests
  
    resources :assistances
  end

end
