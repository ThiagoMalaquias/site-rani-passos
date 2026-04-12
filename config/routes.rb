Rails.application.routes.draw do
  devise_for :users

  root to: "home#index"

  get 'companies', to: 'home#companies'
  get 'courses', to: 'home#courses'
  get 'testimonials', to: 'home#testimonials'
  get 'blogs', to: 'home#blogs'

  get 'courses/:slug/:code/:subcode', to: 'home#metrics'
  get 'courses/:slug', to: 'home#index'

  get 'search', to: 'home#search'
  get 'events', to: 'home#events'

  resources :cart do
    get 'clear_courses', on: :collection
    get 'all_installments', on: :collection
    post 'apply_discount', on: :collection
  end

  resources :promo, only: [:show]
  resources :contacts
  resources :localizations
  resources :user_payments, only: [:index, :create]

  resources :user_site_advertisements do
    get 'add_click', on: :collection
  end

  resources :orders do
    get 'complete-payment/:code', on: :collection, to: 'orders#complete_payment'
  end

  resources :payments, only: [:index, :new, :show, :create] do
    get 'thanks/:code', on: :collection, to: 'payments#thanks'
    get 'cashback_interest/:user_id/:course_id/:authentication_token', on: :collection, to: 'payments#cashback_interest'
    post 'status_webhook', on: :collection
  end

  resources :subscriptions, only: [:index, :new, :show, :create] do
    get 'thanks/:code', on: :collection, to: 'subscriptions#thanks'
    post 'status_webhook', on: :collection
  end

  resources :campaigns do
    post 'status_webhook', on: :collection
  end

  resources :invoices, only: [:create]
end
