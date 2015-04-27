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

    mail to: @admin_email, subject: "WishlistScanner: Daily System Admin Email for #{Date.today.strftime("%a %d %b")}"

  end

end
