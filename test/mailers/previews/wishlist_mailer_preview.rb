class WishlistMailerPreview < ActionMailer::Preview

  def wishlist_results_email
    wishlist = Wishlist.first
    WishlistMailer.wishlist_results_email(wishlist.id)
  end

end