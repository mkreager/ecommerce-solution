class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    helper_method :current_user, :signed_in?, :authenticate_user, :admin_user
    
    private
 
    # Finds the User with the ID stored in the session with the key
    # :current_user_id This is a common way to handle user login in
    # a Rails application; logging in sets the session value and
    # logging out removes it.
    def current_user
        @_current_user ||= session[:current_user_id] &&
            User.find_by(id: session[:current_user_id])
    end
    
    def sign_in_user(user)
        user.expire_token!
        session[:current_user_id] = user.id
    end
    
    def signed_in?
        !current_user.nil?
    end
    
    def authenticate_user
      unless signed_in?
        redirect_to root_url, :notice => "Sorry, that is not permitted."
      end
    end
    
    def admin_user
      unless current_user.admin?
        redirect_to user_path(current_user), :notice => "Sorry, that is not permitted."
      end
    end
    
end
