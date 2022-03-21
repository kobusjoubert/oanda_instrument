Rails.application.routes.draw do
  root 'public#welcome', defaults: { format: 'json' }
  get 'public/welcome', defaults: { format: 'json' }
  devise_for :users, skip: [:sessions, :registrations, :passwords]

  namespace :instruments, defaults: { format: 'json' } do
    get ':instrument/candles', controller: 'candles', action: 'show'
  end
end
