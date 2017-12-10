class UserMailer < ApplicationMailer
    default :from => 'seannak@rogers.com'

    # send a signup email to the user, pass in the user object that   contains the user's email address
    def login_link_email(user)
        @user = user
        mail( :to => @user.email,
        :subject => 'Access link for skphoto.ca' )
    end
end
