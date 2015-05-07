class ApplicationMailer < ActionMailer::Base

  #set a different from name in development environment
  if Rails.env.development?
    default from: "WishlistScanner[DEV] <system@wishlistscanner.com>"
  else
    default from: "WishlistScanner System <system@wishlistscanner.com>"
  end

  layout 'mailer'

  def daily_admin_email(scan_id)
    @scan = Scan.find(scan_id)
    @admin_email = ENV['ADMIN_EMAIL']
    @new_users = User.created_yesterday
    @new_wishlists = Wishlist.created_yesterday

    mail to: @admin_email, subject: "WishlistScanner: Daily System Email for #{Date.today.strftime("%a %d %B")}"

  end


  def new_user_signup_email(user_id)
    @user = User.find(user_id)
    mail to: @admin_mail, subject: "WishlistScanner: New User SignUp on #{Date.today.strftime("%a %d %B")}"
  end

end
