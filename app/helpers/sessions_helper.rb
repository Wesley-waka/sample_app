module SessionsHelper
    def log_in(user)
        session[:user_id] = user.id
    end

    # return current logged-in user(if only)
    def current_user
        @current_user ||= User.find_by(id: session[:user_id])
    end

    # returns true if user is logged in,false otherwise
    def logged_in?
        !current_user.nil?
    end

end
