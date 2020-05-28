module ApplicationCable

  class Connection < ActionCable::Connection::Base

    identified_by :current_user
    identified_by :cohort

    def connect
      self.current_user = find_verified_user
    end

    protected

    def find_verified_user
      # use JWT to auth user
      token = request.params[:token]
      decoded_token = JWT.decode token, ENV['TOKEN_SECRET'], true, { algorithm: 'HS256' }
      reject_unauthorized_connection unless decoded_token
      decoded_token[0]
    end

  end

end
