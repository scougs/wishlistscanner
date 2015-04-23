class WishlistMailer < ApplicationMailer

  layout 'wishlist_mailer'

  def wishlist_results_email(wishlist_id)
    @wishlist = Wishlist.find(wishlist_id)
    @user = @wishlist.user

    mail to: @user.email, subject: "WishlistScanner: Results for #{@wishlist.name}"

  end

end