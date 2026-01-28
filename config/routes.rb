Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  get "up" => "rails/health#show", as: :rails_health_check

  resources :chat_rooms, only: [:index, :show] do
    resources :chat_messages, only: [:index, :create]
  end

  post '/pairing/begin' => 'pairing#begin'
  post '/pairing/leave' => 'pairing#leave'
  get '/pairing/status' => 'pairing#status'

  post '/whereby/create_room' => 'whereby#create_room'
end

