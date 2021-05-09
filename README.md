# Lesson-9 チャット機能
### ①モデルとカラムの作成
ターミナル
```
rails g model room
```
```
rails g model user_room user_id:integer room_id:integer
```
```
rails g model chat user_id:integer room_id:integer message:string
```
```
rails db:migrate
```
### ②コントローラの作成
```
rails g controller chats show
```
### ③アソシエーション
user.rb
```
has_many :user_rooms
has_many :chats
has_many :rooms, through: :user_rooms
```
room.rb
```
has_many :chats
has_many :user_rooms
```
user_room.rb
```
belongs_to :user
belongs_to :room
```
chat.rb
```
belongs_to :user
belongs_to :room
```
### ③ルーティングを追記
```
get 'chat/:id' => 'chats#show', as: 'chat'
resources :chats, only: [:create]
```
### ④users showにview追記
```
      <h2>User info</h2>
      <%= render 'info', user: @user %>
      <% if current_user != @user %>
        <%= link_to 'チャットする', chat_path(@user.id) %>
      <% end %> 
```