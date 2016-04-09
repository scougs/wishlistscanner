class WishlistMailer < ApplicationMailer

  layout 'wishlist_mailer'

  def wishlist_results_email(wishlist_id)
    mg_client = Mailgun::Client.new ENV['MAILGUN_API_KEY']
    @wishlist = Wishlist.find(wishlist_id)
    @user = @wishlist.user
    message_params = {to: @user.email,
                      subject: "WishlistScanner: Results for #{@wishlist.name} on #{Date.today.strftime("%a %d %B")}",
                      from: determine_from_address_based_on_environment,
                      :html => (render_to_string(template: "../views/wishlist_mailer/wishlist_results_email")).to_str
                      }
    mg_client.send_message(sending_domain, message_params)
  end


  def wishlist_first_notify_email(wishlist_id)
    mg_client = Mailgun::Client.new ENV['MAILGUN_API_KEY']
    @wishlist = Wishlist.find(wishlist_id)
    @user = @wishlist.user
    message_params = {to: @user.email,
                      subject: "WishlistScanner: Update for #{@wishlist.name} on #{Date.today.strftime("%a %d %B")}",
                      from: determine_from_address_based_on_environment,
                      :html => (render_to_string(template: "../views/wishlist_mailer/wishlist_first_notify_email")).to_str
                      }
    mg_client.send_message(sending_domain, message_params)
  end


  def wishlist_we_are_still_here(wishlist_id)
    mg_client = Mailgun::Client.new ENV['MAILGUN_API_KEY']
    @wishlist = Wishlist.find(wishlist_id)
    @user = @wishlist.user
    message_params = {to: @user.email,
                      subject: "WishlistScanner: We Are Still Here",
                      from: determine_from_address_based_on_environment,
                      :html => (render_to_string(template: "../views/wishlist_mailer/wishlist_we_are_still_here")).to_str
                      }
    mg_client.send_message(sending_domain, message_params)
  end

end