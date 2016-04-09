class ApplicationMailer < ActionMailer::Base

  def sending_domain
    return 'mg.wishlistscanner.com'
  end

  def determine_from_address_based_on_environment
    #set a different from name in development environment
    if Rails.env.development?
      return "WishlistScanner[DEV] <info@wishlistscanner.com>"
    else
      return "WishlistScanner <info@wishlistscanner.com>"
    end
  end

  layout 'mailer'

  def daily_admin_email(scan_id)
    mg_client = Mailgun::Client.new ENV['MAILGUN_API_KEY']
    @scan = Scan.find(scan_id)
    @admin_email = ENV['ADMIN_EMAIL']
    @new_users = User.created_yesterday
    @new_wishlists = Wishlist.created_yesterday
    message_params = {to: @admin_email,
                      subject: "WishlistScanner: Daily System Email for #{Date.today.strftime("%a %d %B")}",
                      from: determine_from_address_based_on_environment,
                      :html => (render_to_string(template: "../views/application_mailer/daily_admin_email")).to_str
                      }
    mg_client.send_message(sending_domain, message_params)
  end


  def new_user_signup_email(user_id)
    mg_client = Mailgun::Client.new ENV['MAILGUN_API_KEY']
    @user = User.find(user_id)
    message_params = {to: @admin_email,
                      subject: "WishlistScanner: New User SignUp on #{Date.today.strftime("%a %d %B")}",
                      from: determine_from_address_based_on_environment,
                      :html => (render_to_string(template: "../views/application_mailer/new_user_signup_email")).to_str
                      }
    mg_client.send_message(sending_domain, message_params)
  end

end
