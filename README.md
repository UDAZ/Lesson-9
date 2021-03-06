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
### ⑤chatsコントローラーに記述
```
  def show
    @user = User.find(params[:id])
    #ログインしているユーザーのidが入ったroom_idのみを配列で取得（該当するroom_idが複数でも全て取得）
    rooms = current_user.user_rooms.pluck(:room_id)
    #user_idが@user　且つ　room_idが上で取得したrooms配列の中にある数値のもののみ取得(1個または0個のはずです)
    user_rooms = UserRoom.find_by(user_id: @user.id, room_id: rooms)

    if user_rooms.nil? #上記で取得できなかった場合の処理
      #新しいroomを作成して保存
      @room = Room.new
      @room.save
      #@room.idと@user.idをUserRoomのカラムに保存(１レコード)
      UserRoom.create(user_id: @user.id, room_id: @room.id)
      #@room.idとcurrent_user.idをUserRoomのカラムに保存(１レコード)
      UserRoom.create(user_id: current_user.id, room_id: @room.id)
    else
      #取得している場合は、user_roomsに紐づいているroomテーブルのレコードを@roomに代入
      @room = user_rooms.room
    end
    #if文の中で定義した@roomに紐づくchatsテーブルのレコードを代入
    @chats = @room.chats
    #@room.idを代入したChat.newを用意しておく(message送信時のform用)←筆者の表現が合っているか分かりません、、
    @chat = Chat.new(room_id: @room.id)
  end

  def create
    @chat = current_user.chats.new(chat_params)
    @chat.save
  end

  private
  def chat_params
    params.require(:chat).permit(:message, :room_id)
  end
```
### ⑥chats show viewを記述
```
<div class="container">
    <div class="row">
        <div class="col-xs-6">
            <h2 id="room" data-room="<%= @room.id %>" data-user="<%= current_user.id %>"><%= @user.name %> さんとのチャット</h2>
            
            <table class="table">
                <thead>
                    <tr>
                        <th style="text-align:left;font-size:20px;"><%= current_user.name %></th>
                        <th style="text-align:right;font-size:20px;"><%= @user.name %></th>
                    </tr>
                </thead>
                <tbody class="message">
                <% @chats.each do |chat| %>
                    <tr>
                            <% if chat.user_id == current_user.id %>
                            <th colspan="2"style="text-align:left;border:none;">
                                <span style="background-color: greenyellow;border-radius: 4px;padding: 0% 3% 5% 3%;"><%= chat.message %></span>
                            </th>
                            <% else %>
                            <th colspan="2"style="text-align:right;border:none;">
                                <span style="background-color: greenyellow;border-radius: 4px;padding: 0% 3% 5% 3%;"><%= chat.message %></span>
                            </th>
                            <% end %>
                    </tr>                            
                <% end %>
                </tbody>
            </table>
            
            <%= form_with model: @chat, remote: true do |f| %>
                <%= f.text_field :message %>
                <%= f.hidden_field :room_id %>
                <%= f.submit "送信"%>
            <% end %>
        </div>
    </div>
</div>
```
### ⑦create.js.erbの作成
```
$('.message').append("<tr><th colspan='2'style='text-align:left;border:none;'><span style='background-color: greenyellow;border-radius: 4px;padding: 0% 3% 5% 3%;'><%= @chat.message %></span></th></tr>");
$('input[type=text]').val("")
```