class ApplicationMailer < ActionMailer::Base
  default from: "info@wishlistscanner.com"
  layout 'mailer'

  def daily_admin_email(scan_id)
    @scan = Scan.find(scan_id)
    @admin_email = ENV['ADMIN_EMAIL']

    mail to: @admin_email, from: "system@wishlistscanner.com", subject: "WishlistScanner: Daily System Admin Email #{Date.today}"

  end

end
