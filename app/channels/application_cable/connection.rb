module ApplicationCable

  class Connection < ActionCable::Connection::Base

    identified_by :current_user
    identified_by :cohort

    def connect
      self.current_user = find_verified_user
      self.cohort = Cohort.find_by(id: @request.session[:cohort_id]) if @request.session[:cohort_id]
      self.cohort ||= current_user.try(:cohort)
    end

    protected

    def find_verified_user
      reject_unauthorized_connection unless cookies.signed[:user_id]

      if current_user = User.active.find_by(id: cookies.signed[:user_id])
        current_user
      else
        reject_unauthorized_connection
      end
    end

  end

end
