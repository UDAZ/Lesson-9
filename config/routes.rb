Rails.application.routes.draw do
  get 'chats/show'
  devise_for :users
  root 'homes#top'
  resources :users,only: [:show,:index,:edit,:update]
  resources :books
  get 'home/about' => 'homes#about'
  get 'chat/:id' => 'chats#show', as: 'chat'
  resources :chats, only: [:create]
end