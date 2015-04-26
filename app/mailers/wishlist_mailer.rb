class WishlistMailer < ApplicationMailer

  #set a different from name in development environment
  if Rails.env.development?
    default from: "WishlistScanner[DEV] <info@wishlistscanner.com>"
  else
    default from: "WishlistScanner <info@wishlistscanner.com>"
  end

  layout 'wishlist_mailer'

  def wishlist_results_email(wishlist_id)
    @wishlist = Wishlist.find(wishlist_id)
    @user = @wishlist.user

    mail to: @user.email, subject: "WishlistScanner: Results for #{@wishlist.name}"

  end

end