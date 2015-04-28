class Contact < MailForm::Base
  attribute :name,      :validate => true
  attribute :email,     :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :topic
  attribute :message
  attribute :nickname,  :captcha  => true

  # Declare the e-mail headers. It accepts anything the mail method in ActionMailer accepts.
  def headers
    @admin_email = ENV['ADMIN_EMAIL']
    {
      :subject => "WishlistScanner Contact Form",
      :to => @admin_email,
      :from => %("#{name}" <#{email}>)
    }
  end
end
