class ApplicationMailerPreview < ActionMailer::Preview

  def daily_admin_email
    scan = Scan.last
    ApplicationMailer.daily_admin_email(scan.id)
  end

end