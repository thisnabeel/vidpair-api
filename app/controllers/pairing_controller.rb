class PairingController < ApplicationController
  before_action :authenticate_user_from_token!

  def begin
    # Check if user already has a waiting pairing
    existing_pairing = Pairing.find_by(
      user: current_user,
      status: 'waiting'
    )

    if existing_pairing
      return render json: { 
        status: 'waiting',
        pairing_id: existing_pairing.id,
        message: 'Already waiting for a match'
      }
    end

    # Try to find a match
    waiting_pairing = Pairing.waiting_for_match
                              .where.not(user: current_user)
                              .first

    if waiting_pairing
      # Create chat room with both users
      chat_room = ChatRoom.create!(
        user1: waiting_pairing.user,
        user2: current_user,
        status: 'active'
      )

      # Update waiting pairing to matched
      waiting_pairing.update(status: 'matched')

      # Format chat room data for broadcast
      chat_room_data = format_chat_room_for_broadcast(chat_room)
      
      # Convert to JSON and back to ensure it's serializable
      broadcast_data = {
        type: 'matched',
        chat_room: chat_room_data,
        message: 'Match found!'
      }

      # Broadcast match to both users using string-based channel names
      ActionCable.server.broadcast("pairing:#{waiting_pairing.user_id}", broadcast_data)
      ActionCable.server.broadcast("pairing:#{current_user.id}", broadcast_data)

      render json: {
        status: 'matched',
        chat_room: format_chat_room_for_broadcast(chat_room)
      }
    else
      # No match found, create a waiting pairing
      pairing = Pairing.create!(
        user: current_user,
        status: 'waiting'
      )

      render json: {
        status: 'waiting',
        pairing_id: pairing.id,
        message: 'Waiting for match...'
      }
    end
  end

  def leave
    pairing = Pairing.find_by(
      user: current_user,
      status: 'waiting'
    )

    if pairing
      pairing.update(status: 'cancelled')
      render json: { message: 'Left pairing queue' }
    else
      render json: { message: 'Not in pairing queue' }, status: :not_found
    end
  end

  def status
    pairing = Pairing.find_by(
      user: current_user,
      status: 'waiting'
    )

    if pairing
      render json: {
        status: 'waiting',
        pairing_id: pairing.id
      }
    else
      render json: {
        status: 'not_waiting'
      }
    end
  end

  private

  def format_chat_room_for_broadcast(room)
    # Load usernames using pluck to avoid ActiveRecord object serialization
    user_ids = [room.user1_id, room.user2_id].compact
    username_map = User.where(id: user_ids).pluck(:id, :username).each_with_object({}) do |(id, username), hash|
      hash[id] = username
    end
    
    result = {
      'id' => room.id,
      'user1' => {
        'id' => room.user1_id,
        'username' => username_map[room.user1_id] || ''
      },
      'status' => room.status.to_s
    }
    
    if room.user2_id
      result['user2'] = {
        'id' => room.user2_id,
        'username' => username_map[room.user2_id] || ''
      }
    else
      result['user2'] = nil
    end
    
    result
  end
end

