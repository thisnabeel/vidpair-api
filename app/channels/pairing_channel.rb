class PairingChannel < ApplicationCable::Channel
  def subscribed
    stream_from "pairing:#{current_user.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end

