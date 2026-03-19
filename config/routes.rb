Rails.application.routes.draw do
  devise_for :users

  root to: "home#index"
  get 'search', to: 'home#search'
  get 'events', to: 'home#events'

  resources :cart do
    get 'clear_courses', on: :collection
    get 'all_installments', on: :collection
    post 'apply_discount', on: :collection
  end
  resources :leads
  resources :blogs
  resources :teachers
  resources :about_us, only: [:index]
  resources :promo, only: [:show]
  resources :localizations

  resources :contacts
  resources :companies
  resources :testimonials
  resources :live_lessons
  resources :user_payments, only: [:index, :create]

  resources :user_site_advertisements do
    get 'add_click', on: :collection
  end

  resources :orders do
    get 'complete-payment/:code', on: :collection, to: 'orders#complete_payment'
  end

  resources :user_courses do
    get 'thanks', on: :member, to: 'user_courses#thanks'
  end

  resources :courses do
    get 'apply_discount', on: :member
    get ':code/:subcode', on: :member, to: "courses#metrics"
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
