class ChatChannel < ApplicationCable::Channel
  def subscribed
    @chat_room = ChatRoom.find(params[:room_id])
    
    unless @chat_room.participants.include?(current_user)
      reject
      return
    end

    stream_for @chat_room
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    # Handle WebRTC signaling messages
    if ['webrtc_offer', 'webrtc_answer', 'webrtc_ice_candidate', 'webrtc_call_request', 'webrtc_call_end'].include?(data['type'])
      # Broadcast to other participants in the room
      ChatChannel.broadcast_to(@chat_room, {
        type: data['type'],
        from_user_id: current_user.id,
        offer: data['offer'],
        answer: data['answer'],
        candidate: data['candidate']
      })
    # Handle PeerJS peer ID exchange
    elsif data['type'] == 'peerjs_id'
      # Broadcast peer ID to other participants in the room
      ChatChannel.broadcast_to(@chat_room, {
        type: 'peerjs_id',
        peer_id: data['peer_id'],
        from_user_id: current_user.id
      })
    end
  end
end

