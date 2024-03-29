Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'user/sessions' }
  root "articles#index"
  get 'admin', to: 'admin/users#index'
  
  get 'sendmassage' => 'bots#client', as: 'sendmassage'
  
  resources :articles do
    resources :comments
  end

  resources :categories

  namespace :admin do
    resources :users, only: [:index] do
      patch 'update_role', on: :member # Создаем маршрут для обновления роли
      patch 'block', on: :member # Добавляем маршрут для действия "заблокировать"
    end
  end
end