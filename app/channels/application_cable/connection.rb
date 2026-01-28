module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      email = request.params[:email] || request.params[:user_email] || request.headers['X-User-Email']
      token = request.params[:token] || request.params[:user_token] || request.headers['X-User-Token']

      if email.present? && token.present?
        user = User.find_by(email: email)
        if user.present? && user.tokens.present? && user.tokens.include?(token)
          user
        else
          reject_unauthorized_connection
        end
      else
        reject_unauthorized_connection
      end
    end
  end
end

