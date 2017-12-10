class LoginsController < ApplicationController
    
    def new
    end

    def create
        email = params[:email].to_s
        @user = User.find_by email: email

        if !@user
            redirect_to root_path, notice: 'We could not find that email.'
        else
            @user.generate_login_token
            UserMailer.login_link_email(@user).deliver_now
            redirect_to sent_path, notice: 'Check your email for the link.'
        end
    end
    
    def auth
        token = params[:token].to_s
        user = User.find_by(login_token: token)
        
        if signed_in?
            redirect_to user_path(current_user)
        elsif !user
            redirect_to root_path, notice: 'Your link is invalid. Try requesting a new login link.'
        elsif user.login_token_expired?
            redirect_to root_path, notice: 'Your login link has expired. Try requesting a new login link.'
        else
            sign_in_user(user)
            redirect_to user_path(current_user)
        end
    end
    
    def sent
    end
    
    # "Delete" a login, aka "log the user out"
    def destroy
        # Remove the user id from the session
        @_current_user = session[:current_user_id] = nil
        # @_current_user = session[:email] = nil
        redirect_to root_url
    end
end
