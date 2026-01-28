class ChatRoomsController < ApplicationController
  before_action :authenticate_user_from_token!

  def index
    chat_rooms = ChatRoom.where("user1_id = ? OR user2_id = ?", current_user.id, current_user.id)
                        .includes(:user1, :user2)
                        .order(created_at: :desc)
    
    render json: chat_rooms.map { |room| format_chat_room(room) }
  end

  def show
    chat_room = ChatRoom.find(params[:id])
    
    unless chat_room.participants.include?(current_user)
      return head(:forbidden)
    end

    render json: format_chat_room(chat_room)
  end

  private

  def format_chat_room(room)
    {
      id: room.id,
      user1: {
        id: room.user1.id,
        username: room.user1.username,
        email: room.user1.email
      },
      user2: room.user2 ? {
        id: room.user2.id,
        username: room.user2.username,
        email: room.user2.email
      } : nil,
      status: room.status,
      created_at: room.created_at,
      updated_at: room.updated_at
    }
  end
end

