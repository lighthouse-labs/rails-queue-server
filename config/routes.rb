LaserShark::Application.routes.draw do

  resources :queue, only: [:index, :show], controller: 'queue' do
    post 'provided_assistance'
    get 'students', on: :collection
    get 'cohorts', on: :collection
    get 'teachers', on: :collection
    get 'day_activities', on: :collection
    get 'settings', on: :collection
    put 'settings' => 'queue#update_settings', on: :collection
  end

  resource :assistance_requests, only: [:create, :update]

  resource :token, only: [:create]

  resources :compass_instances, only: [:create]

end
