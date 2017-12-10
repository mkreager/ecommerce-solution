class PaymentsController < ApplicationController
  before_action :authenticate_user
  
  def new
    @album = Album.find(params[:album_id])
  end

  def create
    # Amount in cents
    @amount = 4000
  
    customer = Stripe::Customer.create(
      :email => current_user.email,
      :source  => params[:stripeToken]
    )
  
    charge = Stripe::Charge.create(
      :customer       => customer.id,
      :amount         => @amount,
      :description    => 'Album Payment',
      :currency       => 'cad',
      :receipt_email  => current_user.email
    )
    
    if charge["paid"] == true
      album = Album.find(params[:album_id])
      album.paid = true
      album.save!
      if album.save
        redirect_to album, notice: 'Thank you! Your payment has been received.'
      else
        redirect_to album, notice: 'Something went wrong.'
      end
    end
  
  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_charge_path
  end
end
